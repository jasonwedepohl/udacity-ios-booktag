//
//  Tag+CoreDataClass.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
	
	//MARK: Constants
	
	static let entityName = "Tag"
	
	//can't use optional Int32 in Core Data so will use -1 to mean "nil"
	static let nilValueForInt:Int32 = -1
	
	convenience init(_ text: String, _ context: NSManagedObjectContext) {
		if let entityDescription = NSEntityDescription.entity(forEntityName: Tag.entityName, in: context) {
			self.init(entity: entityDescription, insertInto: context)
			self.text = text
			self.totalBooks = Tag.nilValueForInt
		} else {
			fatalError("Unable to initialise object.")
		}
	}
}
