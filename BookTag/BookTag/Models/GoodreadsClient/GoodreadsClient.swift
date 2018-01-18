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
				self.getRandomPageOfBooksForTag(tag, completion)
			} else {
				completion(false, DisplayError.parse)
			}
			
			self.getRandomPageOfBooksForTag(tag, completion)
		}
		
		task.resume()
	}
	
	func getRandomPageOfBooksForTag(_ tag: Tag, _ completion: @escaping (_ successful: Bool, _ displayError: String?) -> ()) {
		
		//TODO: call this method more than once until we have at least 9 books with covers (i.e. books that do not use
		//the Goodreads placeholder images located at https://s.gr-assets.com/assets/nophoto/
		
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
			
			guard let books = self.parseBooksFromSearchResponse(data!) else {
				completion(false, DisplayError.parse)
				return
			}
			
			//TODO: Save books to Core Data
			tag.books = books
			
			//handle completion now so UI shows activity indicators for each book to be downloaded
			completion(true, nil)
			
			//continue to download books in background, FRC will handle updates
			for book in books {
				self.downloadBookImage(fromUrl: book.imageUrl) { (successful, imageData, displayError) in
					if successful {
						//set book image data to image data
						book.imageData = imageData
						
						//TODO: save Core Data here
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
		let path = bookShowPath.replacingOccurrences(of: GoodreadsClient.bookShowPathIDMarker, with: book.id)
		let request = getRequest(withPath: path, withParameters: methodParameters)
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			//TODO: Try parse GoodreadsResponse - if that fails, try parse <error> - if that succeeds, display "unexpected" error message.
			
			//TODO: Save book details to Core Data
			
			completion(true, nil)
		}
		
		task.resume()
	}
	
	private func getSearchRequestParameters(forTag tag: Tag) -> [String:String] {
		return [
			ParameterKeys.apiKey: ParameterValues.apiKey,
			ParameterKeys.query: tag.text
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
	
	private func parseBooksFromSearchResponse(_ data: Data) -> [Book]? {
		let xml = SWXMLHash.parse(data)
		
		let works = xml[XMLTag.goodreadsResponse][XMLTag.search][XMLTag.results][XMLTag.work].all
		
		var books = [Book]()
		for work in works {
			
			guard let rating = work[XMLTag.averageRating].element?.text else {
				//Could not find average_rating tag
				return nil
			}
			
			let bestBook = work[XMLTag.bestBook]
			
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
			
			guard let imageURL = bestBook[XMLTag.imageUrl].element?.text else {
				//Could not find image_url tag
				return nil
			}
			
			let book = Book(bookID, title, author, rating, imageURL)
			books.append(book)
		}
		
		return books
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
}
