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
			"&nbsp;" : " ",
			"<a>" : "",
			"</a>" : "",
			"<b>" : "",
			"</b>" : ""
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
			self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
			self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
			self.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
			self.rating = rating.trimmingCharacters(in: .whitespacesAndNewlines)
			self.imageUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
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
		
		self.isbn = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
		self.isbn13 = isbn13.trimmingCharacters(in: .whitespacesAndNewlines)
		self.bookDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
		self.publishedYear = publishedYear.trimmingCharacters(in: .whitespacesAndNewlines)
		self.numberOfPages = numberOfPages.trimmingCharacters(in: .whitespacesAndNewlines)
		
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
