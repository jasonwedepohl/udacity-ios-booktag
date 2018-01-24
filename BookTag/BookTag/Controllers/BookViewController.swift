//
//  BookViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
	
	//MARK: Constants
	
	let horizontalPadding:CGFloat = 16
	
	//MARK: Properties
	
	let waitingSpinner = WaitingSpinner()
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
		
		//download book details if we don't have them yet
		if book.description == nil {
			
			waitingSpinner.show(view)

			GoodreadsClient.instance.getBookDetails(forBook: book, {successful, displayError in
				DispatchQueue.main.async {
					self.waitingSpinner.hide()
					
					if successful {
						self.setContent()
					} else {
						ErrorAlert.show(self, displayError)
					}
				}
			})
			
		} else {
			setContent()
		}
		
		/*
			Labels that are likely to be longer than the width of the view should have their preferred width limited to the view width
			so that their word wrapping will work properly.
			As a consequence, label widths never exceed the width of the device in portrait mode, so they do not take up the whole width
			of the device in landscape mode. Labels are still wide enough for easy reading.
		*/
		let maxLabelWidth = view.frame.width - horizontalPadding
		titleLabel.preferredMaxLayoutWidth = maxLabelWidth
		authorLabel.preferredMaxLayoutWidth = maxLabelWidth
		descriptionLabel.preferredMaxLayoutWidth = maxLabelWidth
	}
	
	private func setContent() {
		pagesLabel.text = "\(book.numberOfPages!) pages"
		publishedYearLabel.text = "First published in \(book.publicationYear!)"
		ratingLabel.text = "Rating: \(book.rating)/5"
		isbnLabel.text = "ISBN: \(book.isbn!)"
		isbn13Label.text = "ISBN13: \(book.isbn13!)"
		descriptionLabel.text = book.description
	}
}
