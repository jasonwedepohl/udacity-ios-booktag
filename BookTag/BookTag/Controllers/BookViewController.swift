//
//  BookViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class BookViewController: BaseController {
	
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
	
	@IBAction func setNightMode() {
		super.toggleNightMode()
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = book.title
		authorLabel.text = book.author
		coverImage.image = UIImage(data: book.imageData!)
		
		//download book details if we don't have them yet
		if book.bookDescription == nil {
			
			waitingSpinner.show(view)

			GoodreadsClient.instance.getBookDetails(forBook: book, {successful, displayError in
				DispatchQueue.main.async {
					self.waitingSpinner.hide()
					
					if successful {
						self.setDetailLabels()
					} else {
						ErrorAlert.show(self, displayError)
					}
				}
			})
			
		} else {
			setDetailLabels()
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
	
	private func setDetailLabels() {
		//sometimes fields are not provided, so hide their respective labels to avoid empty space
		if book.numberOfPages!.isEmpty {
			pagesLabel.isHidden = true
		} else {
			pagesLabel.text = "\(book.numberOfPages!) pages"
		}
		
		if book.publishedYear!.isEmpty {
			publishedYearLabel.isHidden = true
		} else {
			publishedYearLabel.text = "First published in \(book.publishedYear!)"
		}
		
		if book.rating!.isEmpty {
			ratingLabel.isHidden = true
		} else {
			ratingLabel.text = "Rating: \(book.rating!)/5"
		}
		
		if book.isbn!.isEmpty {
			isbnLabel.isHidden = true
		} else {
			isbnLabel.text = "ISBN: \(book.isbn!)"
		}
		
		if book.isbn13!.isEmpty {
			isbn13Label.isHidden = true
		} else {
			isbn13Label.text = "ISBN13: \(book.isbn13!)"
		}
		
		if book.bookDescription!.isEmpty {
			descriptionLabel.isHidden = true
		} else {
			descriptionLabel.text = book.bookDescription
		}
	}
	
	//MARK: BaseController overrides for night mode
	
	override func useDayColors() {
		super.useDayColors()
		coverImage.backgroundColor = UIColor.white
		titleLabel.textColor = UIColor.black
		authorLabel.textColor = UIColor.lightGray
		ratingLabel.textColor = UIColor.black
		descriptionLabel.textColor = UIColor.black
		pagesLabel.textColor = UIColor.black
		publishedYearLabel.textColor = UIColor.lightGray
		isbnLabel.textColor = UIColor.lightGray
		isbn13Label.textColor = UIColor.lightGray
	}
	
	override func useNightColors() {
		super.useNightColors()
		coverImage.backgroundColor = nightModeBackgroundColor
		titleLabel.textColor = UIColor.white
		authorLabel.textColor = UIColor.lightGray
		ratingLabel.textColor = UIColor.white
		descriptionLabel.textColor = UIColor.white
		pagesLabel.textColor = UIColor.white
		publishedYearLabel.textColor = UIColor.lightGray
		isbnLabel.textColor = UIColor.lightGray
		isbn13Label.textColor = UIColor.lightGray
	}
}
