//
//  Book+CoreDataProperties.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var rating: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var numberOfPages: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var isbn: String?
    @NSManaged public var isbn13: String?
    @NSManaged public var publishedYear: String?
    @NSManaged public var tag: Tag?

}
