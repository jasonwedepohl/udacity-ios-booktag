//
//  CollageViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit
import CoreData

class CollageViewController: UIViewController {
	
	//MARK: Constants
	
	let bookSegueIdentifier = "BookSegue"
	let cellIdentifier = "BookCell"
	let cellsPerRow:CGFloat = 3;
	let cellSpacing:CGFloat = 2;
	
	//MARK: Properties
	
	let waitingSpinner = WaitingSpinner()
	var tag: Tag!
	
	//MARK: Outlets
	
	@IBOutlet var tagText: UILabel!
	@IBOutlet var bookCollectionView: UICollectionView!
	@IBOutlet var bookCollectionViewFlowLayout: UICollectionViewFlowLayout!
	@IBOutlet var rerollCollageButton: UIBarButtonItem!
	@IBOutlet var noBooksLabel: UILabel!
	
	//TODO: Hook up Share button
	
	//MARK: Actions
	
	@IBAction func rerollCollage() {
		waitingSpinner.show(view)
		noBooksLabel.isHidden = true
		rerollCollageButton.isEnabled = false
		
		//TODO: delete books for the current tag from the main context
		
		if tag.totalBooks == Tag.nilValueForInt {
			//we don't know the number of pages of books for this tag yet
			GoodreadsClient.instance.getBooksForTag(tag, completionForNewCollection(_:_:))
		} else {
			//we know the number of pages, so choose a random one
			GoodreadsClient.instance.getRandomPageOfBooksForTag(tag, completionForNewCollection(_:_:))
		}
	}
	
	private func completionForNewCollection(_ successful: Bool, _ displayError: String?) {
		DispatchQueue.main.async {
			self.waitingSpinner.hide()
			self.rerollCollageButton.isEnabled = true
			
			if successful {
				if self.tag.totalBooks == 0 {
					self.noBooksLabel.isHidden = false
				} else {
					//TODO: fetch books for tag from main context
					self.bookCollectionView.reloadData()
				}
			} else {
				ErrorAlert.show(self, displayError)
			}
		}
	}
	
	@IBAction func goBack(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tagText.text = tag.text
		
		setFlowLayout()
		
		//TODO: initialise FRC with a fetch request for the given tag's books using the main context
		
		if (tag.totalBooks == Tag.nilValueForInt) {
			rerollCollage()
		} else if (tag.totalBooks == 0) {
			noBooksLabel.isHidden = false
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == bookSegueIdentifier {
			guard let bookController = segue.destination as? BookViewController else {
				print("Expected segue destination to be BookViewController but was \(String(describing: segue.destination))")
				return
			}
			
			guard let book = sender as? Book else {
				print("Expected sender to be a book but was \(String(describing: sender))")
				return
			}
			
			bookController.book = book
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		//change flow layout as orientation changes
		coordinator.animate(alongsideTransition: { _ in
			self.setFlowLayout()
		}, completion: nil)
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		//change flow layout after orientation changes
		setFlowLayout()
	}
	
	private func setFlowLayout() {
		if bookCollectionViewFlowLayout == nil {
			/*
			sometimes flowLayout is nil during orientation change
			e.g. if simulator is in landscape mode, app launches in portrait mode then rotates immediately, before the view has been loaded
			*/
			return;
		}
		
		let numberOfSpaces:CGFloat = 2 * (cellsPerRow - 1)
		let dimension = (view.frame.width - (numberOfSpaces * cellSpacing)) / cellsPerRow
		
		bookCollectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
		bookCollectionViewFlowLayout.minimumLineSpacing = cellSpacing
		bookCollectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
	}
}

//MARK: UICollectionViewDataSource + UICollectionViewDelegate extension

extension CollageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	/*func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		//TODO: use FCR
	}*/
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		//TODO: use FCR
		return tag.books.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BookCollectionViewCell
		
		//TODO: use FCR
		let book = tag.books[indexPath.row]
		
		cell.imageView.backgroundColor = UIColor.white
		cell.imageView.contentMode = .scaleAspectFill
		
		if let imageData = book.imageData {
			cell.imageView.image = UIImage(data: imageData)
			cell.loadingIndicator.stopAnimating()
			cell.loadingIndicator.isHidden = true
		}
		else {
			cell.loadingIndicator.isHidden = false
			cell.loadingIndicator.startAnimating()
			cell.imageView.image = nil
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let book = tag.books[indexPath.row]
		if book.imageData != nil {
			performSegue(withIdentifier: bookSegueIdentifier, sender: tag.books[indexPath.row])
		}
	}
}

//MARK: NSFetchedResultsControllerDelegate implementation

extension CollageViewController: NSFetchedResultsControllerDelegate {
	//TODO: Fill this in
}
