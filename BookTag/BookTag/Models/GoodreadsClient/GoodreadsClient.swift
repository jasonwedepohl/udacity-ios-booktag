//
//  GoodreadsClient.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation
import SWXMLHash

class GoodreadsClient {
	
	//MARK: Singleton
	
	static let instance = GoodreadsClient()
	
	//MARK: Constants
	
	let apiScheme = "https"
	let apiHost = "www.goodreads.com"
	let bookSearchPath = "/search/index.xml"
	static let bookShowPathIDMarker = "{id}"
	let bookShowPath = "/book/show/\(bookShowPathIDMarker).xml"
	
	//the GoodReads book search page size is fixed at 10 and cannot be set
	let pageSize:Int32 = 10
	
	//the GoodReads API sometimes returns the same page of books if the page parameter is too high, even if the page falls within the total book count!
	//Goodreads does not explain this behaviour in their API documentation. I suspect Goodreads is temporarily caching the results for high page counts.
	let goodreadsMaxPage:Int32 = 100
	
	//books without a cover image are assigned the url of a generic Goodreads logo image
	let goodreadsNoCoverImageUrl = "https://s.gr-assets.com/assets/nophoto/"
	
	//number of books we want to grab per collage
	let collageBookCount = 12
	
	//Goodreads states that calls must be no less than 1 second apart
	let goodreadsSleepSeconds = 1
	
	//max number of times we want to call the search function to get books for a collage - multiple calls are needed since the Goodreads page size is 10
	//and often there are books without cover images, which we want to exclude from the results
	let maxSearchRetryCount = 4
	
	struct ParameterKeys {
		static let apiKey = "key"
		static let page = "page"
		static let query = "q"
	}
	
	struct ParameterValues {
		static let apiKey = "EHe5XpuHeb7hmcw0lhPg"
	}
	
	struct XMLTag {
		static let goodreadsResponse = "GoodreadsResponse"
		static let search = "search"
		static let error = "error"
		static let totalResults = "total-results"
		static let results = "results"
		static let work = "work"
		static let averageRating = "average_rating"
		static let bestBook = "best_book"
		static let id = "id"
		static let title = "title"
		static let author = "author"
		static let name = "name"
		static let imageUrl = "image_url"
		static let isbn = "isbn"
		static let isbn13 = "isbn13"
		static let publicationYear = "original_publication_year"
		static let book = "book"
		static let description = "description"
		static let numPages = "num_pages"
	}
	
	//MARK: Functions
	
	func getBooksForTag(_ tag: Tag, _ completion: @escaping (_ successful: Bool, _ displayError: String?) -> ()) {
		
		let methodParameters = getSearchRequestParameters(forTag: tag)
		let request = getRequest(withPath: bookSearchPath, withParameters: methodParameters)
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			//tag was loaded in main context, so this change will be persisted to Core Data when app closes (in AppDelegate)
			if let totalBooks = self.parseTotalBooksFromSearchResponse(data!) {
				tag.totalBooks = totalBooks
				
				//if there aren't any books for the tag we know we don't need to go further
				if tag.totalBooks == 0 {
					completion(true, nil)
				} else {
					self.getRandomPageOfBooksForTag(tag, 0, [], completion)
				}
			} else {
				completion(false, DisplayError.parse)
			}
		}
		
		task.resume()
	}
	
	func getRandomPageOfBooksForTag(_ tag: Tag,
									_ callCount: Int,
									_ booksToAdd: [BookResult],
									_ completion: @escaping (_ successful: Bool, _ displayError: String?) -> ()) {
		
		//booksToAdd is a running collection of the books added to a tag. We need to keep track of this because
		//this function can be called up to four times until enough suitable books have been found. Only when
		//this recursive chain is complete are the books stored to the Core Data main context.
		var booksToAdd = booksToAdd
		
		let maxPage = min(goodreadsMaxPage, max(1, tag.totalBooks / pageSize - 1))
		let randomPage = Int(arc4random_uniform(UInt32(maxPage))) + 1
		
		var methodParametersWithPageNumber = getSearchRequestParameters(forTag: tag)
		methodParametersWithPageNumber[ParameterKeys.page] = String(randomPage)
		
		var request = getRequest(withPath: bookSearchPath, withParameters: methodParametersWithPageNumber)
		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			guard let currentRecursionBookResults = self.parseBooksFromSearchResponse(data!) else {
				completion(false, DisplayError.parse)
				return
			}
			
			if currentRecursionBookResults.count > 0 {
				let numberOfBooksThatCanBeAdded = self.collageBookCount - booksToAdd.count
				let numberOfBooksThatWillBeAdded = min(numberOfBooksThatCanBeAdded, currentRecursionBookResults.count)
				let indexOfLastBookToAdd = min(numberOfBooksThatWillBeAdded, currentRecursionBookResults.count - 1)
				
				booksToAdd.append(contentsOf: currentRecursionBookResults[0..<indexOfLastBookToAdd])
			}
			
			//check if we have enough books for a collage - if not, check if we haven't hit our limit on search retries
			if booksToAdd.count < self.collageBookCount && callCount < self.maxSearchRetryCount {
				
				//following Goodreads API rules, wait 1 second before making the next call
				DispatchQueue.main.asyncAfter(deadline: (.now() + .seconds(self.goodreadsSleepSeconds)), execute: {
				
					//call recursively with an incremented call count
					self.getRandomPageOfBooksForTag(tag, callCount + 1, booksToAdd, completion)
				})
				
				//skip saving to Core Data and downloading book images until we have enough books
				return
			}
			
			var books = [Book]()
			for bookResult in booksToAdd {
				
				//create book in main context
				let book = Book(bookResult.id,
								bookResult.title,
								bookResult.author,
								bookResult.rating,
								bookResult.imageUrl,
								tag,
								CoreDataStack.instance.context)
				books.append(book)
			}
			
			//save books to Core Data main context
			CoreDataStack.instance.save()
			
			//handle completion now so UI shows activity indicators for each book to be downloaded
			completion(true, nil)
			
			//continue to download books in background, FRC will handle updates
			for book in books {
				self.downloadBookImage(fromUrl: book.imageUrl!) { (successful, imageData, displayError) in
					if successful {
						//set book image data to image data
						book.imageData = imageData
						CoreDataStack.instance.save()
					} else {
						print("Could not download image: \(displayError!)")
					}
				}
			}
		}
		
		task.resume()
	}
	
	private func downloadBookImage(fromUrl urlString: String, _ completion: @escaping (_ successful: Bool, _ data: Data?, _ displayError: String?) -> ()) {
		let url = URL(string: urlString)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, nil, responseError)
				return
			}
			
			completion(true, data!, nil)
		}
		
		task.resume()
	}
	
	func getBookDetails(forBook book: Book, _ completion: @escaping (_ successful: Bool, _ displayError: String?) -> ()) {
		
		let methodParameters = [ ParameterKeys.apiKey: ParameterValues.apiKey ]
		let path = bookShowPath.replacingOccurrences(of: GoodreadsClient.bookShowPathIDMarker, with: book.id!)
		let request = getRequest(withPath: path, withParameters: methodParameters)
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			if !self.parseDetails(forBook: book, data!) {
				completion(false, DisplayError.parse)
				return
			}
			
			//save book details in main context
			CoreDataStack.instance.save()
			
			completion(true, nil)
		}
		
		task.resume()
	}
	
	private func getSearchRequestParameters(forTag tag: Tag) -> [String:String] {
		return [
			ParameterKeys.apiKey: ParameterValues.apiKey,
			ParameterKeys.query: tag.text!
		]
	}
	
	private func getRequest(withPath path: String, withParameters parameters: [String:String]) -> URLRequest {
		
		var components = URLComponents()
		components.scheme = apiScheme
		components.host = apiHost
		components.path = path
		components.queryItems = [URLQueryItem]()
		
		for (key, value) in parameters {
			let queryItem = URLQueryItem(name: key, value: "\(value)")
			components.queryItems!.append(queryItem)
		}
		
		return URLRequest(url: components.url!)
	}
	
	private func parseTotalBooksFromSearchResponse(_ data: Data) -> Int32? {
		let xml = SWXMLHash.config { config in config.shouldProcessLazily = true }
						   .parse(data)
		
		guard let totalBooks = xml[XMLTag.goodreadsResponse][XMLTag.search][XMLTag.totalResults].element?.text else {
			//Could not find total-results tag
			return nil
		}
		
		return Int32(totalBooks)
	}
	
	private func parseBooksFromSearchResponse(_ data: Data) -> [BookResult]? {
		let xml = SWXMLHash.parse(data)
		
		let works = xml[XMLTag.goodreadsResponse][XMLTag.search][XMLTag.results][XMLTag.work].all
		
		var bookResults = [BookResult]()
		for work in works {
			
			guard let rating = work[XMLTag.averageRating].element?.text else {
				//Could not find average_rating tag
				return nil
			}
			
			let bestBook = work[XMLTag.bestBook]
			
			guard let imageURL = bestBook[XMLTag.imageUrl].element?.text else {
				//Could not find image_url tag
				return nil
			}
			
			//if the book has no cover image, we don't want to include it in the results
			if imageURL.starts(with: goodreadsNoCoverImageUrl) {
				continue
			}
			
			guard let bookID = bestBook[XMLTag.id].element?.text else {
				//Could not find ID tag
				return nil
			}
			
			guard let title = bestBook[XMLTag.title].element?.text else {
				//Could not find title tag
				return nil
			}
			
			guard let author = bestBook[XMLTag.author][XMLTag.name].element?.text else {
				//Could not find author tag
				return nil
			}
			
			let bookResult = BookResult(id: bookID, title: title, imageUrl: imageURL, rating: rating, author: author)
			bookResults.append(bookResult)
		}
		
		return bookResults
	}
	
	private func parseDetails(forBook book: Book, _ data: Data) -> Bool {
		let xml = SWXMLHash.parse(data)
		
		let bookXML = xml[XMLTag.goodreadsResponse][XMLTag.book]
		
		guard let isbn = bookXML[XMLTag.isbn].element?.text else {
			//Could not find isbn tag
			return false
		}
		
		guard let isbn13 = bookXML[XMLTag.isbn13].element?.text else {
			//Could not find isbn13 tag
			return false
		}
		
		guard let description = bookXML[XMLTag.description].element?.text else {
			//Could not find description tag
			return false
		}
		
		guard let publicationYear = bookXML[XMLTag.work][XMLTag.publicationYear].element?.text else {
			//Could not find original_publication_year tag
			return false
		}
		
		guard let numberOfPages = bookXML[XMLTag.numPages].element?.text else {
			//Could not find num_pages tag
			return false
		}
		
		book.setDetails(isbn, isbn13, description, publicationYear, numberOfPages)
		
		return true
	}
	
	struct BookResult {
		let id: String
		let title: String
		let imageUrl: String
		let rating: String
		let author: String
	}
}
