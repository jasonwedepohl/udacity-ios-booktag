//
//  Book+CoreDataClass.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation
import CoreData

@objc(Book)
public class Book: NSManagedObject {
	
	//MARK: Constants
	
	private static let entityName = "Book"
	
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
	
	convenience init(_ id: String,
					 _ title: String,
					 _ author: String,
					 _ rating: String,
					 _ imageUrl: String,
					 _ tag: Tag,
					 _ context: NSManagedObjectContext) {
		
		if let entityDescription = NSEntityDescription.entity(forEntityName: Book.entityName, in: context) {
			self.init(entity: entityDescription, insertInto: context)
			self.id = id
			self.title = title
			self.author = author
			self.rating = rating
			self.imageUrl = imageUrl
			self.tag = tag
		} else {
			fatalError("Unable to initialise object.")
		}
	}
	
	func setDetails(_ isbn: String,
					_ isbn13: String,
					_ description: String,
					_ publishedYear: String,
					_ numberOfPages: String) {
		
		self.isbn = isbn
		self.isbn13 = isbn13
		self.bookDescription = description
		self.publishedYear = publishedYear
		self.numberOfPages = numberOfPages
		
		//sanitise description, replacing HTML markup with desirable equivalents (see above comment)
		for keyValue in undesirableDescriptionStringReplacements {
			self.bookDescription = self.bookDescription?.replacingOccurrences(of: keyValue.key, with: keyValue.value)
		}
	}
	
	static func getFetchRequest(forTag tag: Tag) -> NSFetchRequest<NSFetchRequestResult> {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Book.entityName)
		fetchRequest.sortDescriptors = []
		fetchRequest.predicate = NSPredicate(format: "tag == %@", tag)
		return fetchRequest
	}
}
