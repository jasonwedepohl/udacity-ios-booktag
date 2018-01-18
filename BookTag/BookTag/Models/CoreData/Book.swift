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
	
	init(_ id: String, _ title: String, _ author: String, _ rating: String, _ imageUrl: String) {
		self.id = id
		self.title = title
		self.author = author
		self.rating = rating
		self.imageUrl = imageUrl
	}
	
	func setDetails(_ description: String, _ isbn: String, _ isbn13: String, _ publicationYear: String, _ numberOfPages: String) {
		self.description = description
		self.isbn = isbn
		self.isbn13 = isbn13
		self.publicationYear = publicationYear
		self.numberOfPages = numberOfPages
	}
}
