//
//  CollageViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit
import CoreData

class CollageViewController: BaseController {
	
	//MARK: Constants
	
	let bookSegueIdentifier = "BookSegue"
	let cellIdentifier = "BookCell"
	let cellsPerRow:CGFloat = 3;
	let cellSpacing:CGFloat = 2;
	let defaultTagBackgroundColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 230.0/255.0, alpha: 1.0)
	
	//MARK: Properties
	
	let waitingSpinner = WaitingSpinner()
	var tag: Tag!
	var insertedIndexPaths: [IndexPath]!
	var updatedIndexPaths: [IndexPath]!
	var deletedIndexPaths: [IndexPath]!
	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
	
	//MARK: Outlets
	
	@IBOutlet var tagText: UILabel!
	@IBOutlet var bookCollectionView: UICollectionView!
	@IBOutlet var bookCollectionViewFlowLayout: UICollectionViewFlowLayout!
	@IBOutlet var rerollCollageButton: UIBarButtonItem!
	@IBOutlet var noBooksLabel: UILabel!
	@IBOutlet var tagPlaceholderTop: UIView!
	@IBOutlet var tagPlaceholderBottom: UIView!
	
	//MARK: Actions
	
	@IBAction func rerollCollage() {
		waitingSpinner.show(view)
		noBooksLabel.isHidden = true
		rerollCollageButton.isEnabled = false
		
		//delete books for the current tag from the main context
		if let books = fetchedResultsController.fetchedObjects as? [Book] {
			for book in books {
				CoreDataStack.instance.context.delete(book)
			}
		}
		CoreDataStack.instance.save()
		
		if tag.totalBooks == Tag.nilValueForInt {
			//we don't know the number of pages of books for this tag yet
			GoodreadsClient.instance.getBooksForTag(tag, completionForNewCollection(_:_:))
		} else {
			//we know the number of pages, so choose a random one
			GoodreadsClient.instance.getRandomPageOfBooksForTag(tag, 0, [], completionForNewCollection(_:_:))
		}
	}
	
	private func completionForNewCollection(_ successful: Bool, _ displayError: String?) {
		DispatchQueue.main.async {
			self.waitingSpinner.hide()
			self.rerollCollageButton.isEnabled = true
			
			if successful {
				if self.tag.totalBooks == 0 {
					self.noBooksLabel.isHidden = false
					self.rerollCollageButton.isEnabled = false
				} else {
					//fetch books for tag from main context
					self.performFetch()
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
	
	@IBAction func setNightMode() {
		super.toggleNightMode()
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tagText.text = tag.text
		
		setFlowLayout()
		
		//init FRC and tell it to get books for the given tag from main context
		let fetchRequest = Book.getFetchRequest(forTag: tag)
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
															  managedObjectContext: CoreDataStack.instance.context,
															  sectionNameKeyPath: nil,
															  cacheName: nil)
		fetchedResultsController.delegate = self
		performFetch()
		
		if (tag.totalBooks == Tag.nilValueForInt) {
			rerollCollage()
		} else if (tag.totalBooks == 0) {
			noBooksLabel.isHidden = false
			rerollCollageButton.isEnabled = false
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == bookSegueIdentifier {
			guard let bookNavigationController = segue.destination as? UINavigationController else {
				print("Expected segue destination to be UINavigationController but was \(String(describing: segue.destination))")
				return
			}
			
			guard let bookController = bookNavigationController.viewControllers.first as? BookViewController else {
				print("Expected segue destination child to be BookViewController but was \(String(describing: segue.destination))")
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
	
	//MARK: BaseController overrides for night mode
	
	override func useDayColors() {
		super.useDayColors()
		bookCollectionView.backgroundColor = UIColor.white
		tagPlaceholderTop.backgroundColor = defaultTagBackgroundColor
		tagPlaceholderBottom.backgroundColor = defaultTagBackgroundColor
		tagText.backgroundColor = defaultTagBackgroundColor
		tagText.textColor = UIColor.white
	}
	
	override func useNightColors() {
		super.useNightColors()
		bookCollectionView.backgroundColor = nightModeBackgroundColor
		tagPlaceholderTop.backgroundColor = nightModeBackgroundColor
		tagPlaceholderBottom.backgroundColor = nightModeBackgroundColor
		tagText.backgroundColor = nightModeBackgroundColor
		tagText.textColor = UIColor.cyan
	}
}

//MARK: UICollectionViewDataSource + UICollectionViewDelegate extension

extension CollageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections.count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections[section].numberOfObjects
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BookCollectionViewCell
		let book = fetchedResultsController.object(at: indexPath) as! Book
		
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
		let book = fetchedResultsController.object(at: indexPath) as! Book
		if book.imageData != nil {
			performSegue(withIdentifier: bookSegueIdentifier, sender: book)
		}
	}
}

//MARK: NSFetchedResultsControllerDelegate implementation

extension CollageViewController: NSFetchedResultsControllerDelegate {
	
	func performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch let e as NSError {
			print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
		}
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexPaths = []
		updatedIndexPaths = []
		deletedIndexPaths = []
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			insertedIndexPaths.append(newIndexPath!)
		case .delete:
			deletedIndexPaths.append(indexPath!)
		case .update:
			updatedIndexPaths.append(indexPath!)
		case .move:
			print("We aren't doing moves so this should never be seen.")
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		bookCollectionView.performBatchUpdates({
			self.bookCollectionView.insertItems(at: self.insertedIndexPaths)
			self.bookCollectionView.deleteItems(at: self.deletedIndexPaths)
			self.bookCollectionView.reloadItems(at: self.updatedIndexPaths)
		}, completion: nil)
	}
}
