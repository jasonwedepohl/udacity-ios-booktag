//
//  CollageViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class CollageViewController: UIViewController {
	
	//MARK: Properties
	
	var tag: Tag!
	
	//MARK: Outlets
	
	@IBOutlet var tagText: UILabel!
	
	//MARK: UIViewController overrides

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tagText.text = tag.text
    }

}
