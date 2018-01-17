//
//  GoodreadsClient.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation

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
		static let publicationYear = "publication_year"
		static let publicationMonth = "publication_month"
		static let publicationDay = "publicationDay"
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
			
			let dataString = String(data: data!, encoding: .utf8)
			
			//TODO: Try parse GoodreadsResponse - if that fails, try parse <error> - if that succeeds, display "unexpected" error message.
			
			//set search result stats on tag so they can be reused
			//tag was loaded in main context, so this change will be persisted to Core Data when app closes (in AppDelegate)
			//tag.totalBooks = Int32(parsedResponse.books.total)!
			
			self.getRandomPageOfBooksForTag(tag, completion)
		}
		
		task.resume()
	}
	
	func getRandomPageOfBooksForTag(_ tag: Tag, _ completion: @escaping (_ successful: Bool, _ displayError: String?) -> ()) {
		
		let maxPage = max(1, tag.totalBooks / pageSize - 1)
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
			
			//TODO: Try parse GoodreadsResponse - if that fails, try parse <error> - if that succeeds, display "unexpected" error message.
			
			//TODO: Save books to Core Data
			
			//TODO: download book images in background
			
			completion(true, nil)
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
}
