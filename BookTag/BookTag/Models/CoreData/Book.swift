//
//  Book.swift
//  BookTag
//
//  Created by Jason Wedepohl on 2018/01/17.
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation

class Book {
	let id: String
	let title: String
	let author: String
	let rating: Double
	let imageUrl: String
	
	var imageData: Data?
	var description: String?
	var isbn: String?
	var isbn13: String?
	var publicationYear: Int32?
	var publicationMonth: Int32?
	var publicationDay: Int32?
	
	init(id: String, title: String, author: String, rating: Double, imageUrl: String) {
		self.id = id
		self.title = title
		self.author = author
		self.rating = rating
		self.imageUrl = imageUrl
	}
	
	func setDetails(description: String, isbn: String, isbn13: String, publicationYear: Int32, publicationMonth: Int32, publicationDay: Int32) {
		self.description = description
		self.isbn = isbn
		self.isbn13 = isbn13
		self.publicationYear = publicationYear
		self.publicationMonth = publicationMonth
		self.publicationDay = publicationDay
	}
}
