//
//  TagViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import CoreData
import UIKit

class TagViewController: UIViewController {
	
	//MARK: Constants
	
	let collageSegueIdentifier = "CollageSegue"
	
	//MARK: Actions
	
	@IBAction func addTag() {
		//TODO: Add tag to core data and segue to collage view with tag as a parameter.
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//TODO: load all tags from main context into table view
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == collageSegueIdentifier {
			guard let collageController = segue.destination as? CollageViewController else {
				print("Expected segue destination to be CollageViewController but was \(String(describing: segue.destination))")
				return
			}
			
			guard let tag = sender as? Tag else {
				print("Expected sender to be a Tag but was \(String(describing: sender))")
				return
			}
			
			collageController.tag = tag
		}
	}
}

