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
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var ratingLabel: UILabel!
	@IBOutlet var pagesLabel: UILabel!
	@IBOutlet var publishedYearLabel:UILabel!
	@IBOutlet var isbnLabel: UILabel!
	@IBOutlet var isbn13Label: UILabel!
	
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
		
		if book.description == nil {
			//TODO: load book details
		} else {
			pagesLabel.text = "\(book.numberOfPages!) pages"
			publishedYearLabel.text = "First published in \(book.publicationYear!)"
			ratingLabel.text = "Rating: \(book.rating)/5"
			isbnLabel.text = "ISBN: \(book.isbn!)"
			isbn13Label.text = "ISBN13: \(book.isbn13!)"
			descriptionLabel.text = book.description
		}
	}
}
