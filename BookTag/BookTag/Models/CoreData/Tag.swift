//
//  Tag.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

//dummy class to allow testing before adding Core Data
class Tag {
	//can't use optional Int32 in Core Data so will use -1 to mean "nil"
	static let nilValueForInt:Int32 = -1
	
	var text:String
	var totalBooks:Int32
	
	init(text: String) {
		self.text = text
		totalBooks = Tag.nilValueForInt
	}
}
