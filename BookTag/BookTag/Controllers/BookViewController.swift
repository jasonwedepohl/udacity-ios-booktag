//
//  BookViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
	
	//MARK: Properties
	
	var book: Book!
	
	//MARK: Outlets
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var authorLabel: UILabel!
	@IBOutlet var coverImage: UIImageView!
	@IBOutlet var ratingLabel: UILabel! //TODO: Use a UIImage with some image resources to show star rating
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var isbnLabel: UILabel!
	@IBOutlet var isbn13Label: UILabel!
	@IBOutlet var publicationYearLabel: UILabel!
	@IBOutlet var numPagesLabel: UILabel!
	
	//MARK: Actions
	
	@IBAction func close() {
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = book.title
		authorLabel.text = book.author
		coverImage.image = UIImage(data: book.imageData!)
		ratingLabel.text = book.rating
		
		/* TODO: Load these if they aren't set yet
		descriptionLabel.text = book.description
		isbnLabel.text = book.isbn
		isbn13Label.text = book.isbn13
		publicationYearLabel.text = book.publicationYear
		numPagesLabel.text = book.numberOfPages
		*/
	}
}
