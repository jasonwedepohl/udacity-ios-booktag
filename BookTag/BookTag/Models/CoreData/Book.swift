//
//  Book.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation

class Book {
	let id: String
	let title: String
	let author: String
	let rating: String
	let imageUrl: String
	
	var imageData: Data?
	var description: String?
	var isbn: String?
	var isbn13: String?
	var publicationYear: String?
	var numberOfPages: String?
	
	//Descriptions from Goodreads sometimes contain some HTML markup.
	//If there are italics (<i>), the app replaces them with quotes.
	//If there are line breaks (<br />), the app replaces them with newlines.
	//The more common HTML character codes such as &amp; and &quot; are replaced with their Unicode equivalents.
	let undesirableDescriptionStringReplacements =
		[
			"<i>": "\"",
			"</i>" : "\"",
			"<br />" : "\n",
			"<em>" : "",
			"</em>" : "",
			"&amp;" : "&",
			"&apos;" : "'",
			"&quot;" : "\"",
			"&lt;" : "<",
			"&gt;" : ">",
			"&nbsp;" : " "
		]
	
	init(_ id: String, _ title: String, _ author: String, _ rating: String, _ imageUrl: String) {
		self.id = id
		self.title = title
		self.author = author
		self.rating = rating
		self.imageUrl = imageUrl
	}
	
	func setDetails(_ isbn: String, _ isbn13: String, _ description: String, _ publicationYear: String, _ numberOfPages: String) {
		self.isbn = isbn
		self.isbn13 = isbn13
		self.description = description
		self.publicationYear = publicationYear
		self.numberOfPages = numberOfPages
		
		//sanitise description, replacing HTML markup with desirable equivalents (see above comment)
		for keyValue in undesirableDescriptionStringReplacements {
			self.description = self.description?.replacingOccurrences(of: keyValue.key, with: keyValue.value)
		}
	}
}
