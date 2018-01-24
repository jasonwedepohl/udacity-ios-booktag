//
//  TagViewController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import CoreData
import UIKit

class TagViewController: BaseController {
	
	//MARK: Constants
	
	let collageSegueIdentifier = "CollageSegue"
	let cellIdentifier = "TagCell"
	
	//MARK: Properties
	
	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
	var tableCellBackgroundColor: UIColor!
	var tableCellTextColor: UIColor!
	
	//MARK: Outlets
	
	@IBOutlet var tagTableView: UITableView!
	@IBOutlet var noTagsLabel: UILabel!
	@IBOutlet var addButton: UIBarButtonItem!
	@IBOutlet var toggleNightModeButton: UIBarButtonItem!
	
	//MARK: Actions
	
	@IBAction func openAddTagDialog() {
		let alert = UIAlertController(title: "Add a tag", message: "", preferredStyle: .alert)
		
		alert.addTextField(configurationHandler: nil)
		
		alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [alert] (_) in
			let textField = alert.textFields![0]
			
			//add tag to core data
			let tag = Tag(textField.text!, CoreDataStack.instance.context)
			CoreDataStack.instance.save()
			
			self.performSegue(withIdentifier: self.collageSegueIdentifier, sender: tag)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func setNightMode() {
		super.toggleNightMode()
	}
	
	//MARK: UIViewController overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//init FRC and tell it to get all tags from main context
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Tag.entityName)
		fetchRequest.sortDescriptors = []
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
															  managedObjectContext: CoreDataStack.instance.context,
															  sectionNameKeyPath: nil,
															  cacheName: nil)
		fetchedResultsController.delegate = self
		performFetch()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Count the tags - if there are no tags, hide the table view and show the "no tags" label
		if let sections = fetchedResultsController.sections {
			if sections.count == 1 {
				let tagCount = sections[0].numberOfObjects
				tagTableView.isHidden = tagCount == 0
				noTagsLabel.isHidden = tagCount != 0
			}
		}
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
			
			//set back bar title on Collage view to "Back", not "Booktag"
			let backItem = UIBarButtonItem()
			backItem.title = "Back"
			navigationItem.backBarButtonItem = backItem
		}
	}
	
	//MARK: BaseController overrides for night mode
	
	override func useDayColors() {
		super.useDayColors()
		
		tagTableView.separatorColor = iosDefaultTint
		tagTableView.backgroundColor = UIColor.white
		tableCellTextColor = UIColor.black
		tableCellBackgroundColor = UIColor.white
		setTableCellColors()
		
		addButton.tintColor = iosDefaultTint
		toggleNightModeButton.tintColor = iosDefaultTint
	}
	
	override func useNightColors() {
		super.useNightColors()
		
		tagTableView.separatorColor = UIColor.cyan
		tagTableView.backgroundColor = nightModeBackgroundColor
		tableCellTextColor = UIColor.white
		tableCellBackgroundColor =  nightModeBackgroundColor
		setTableCellColors()
		
		addButton.tintColor = UIColor.white
		toggleNightModeButton.tintColor = UIColor.white
	}
	
	private func setTableCellColors() {
		for cell in tagTableView.visibleCells {
			cell.textLabel?.textColor = tableCellTextColor
			cell.backgroundColor = tableCellBackgroundColor
			cell.tintColor = tableCellBackgroundColor
		}
	}
}

//MARK: UITableViewDelegate and UITableViewDataSource
var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
extension TagViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections[section].numberOfObjects
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let tag = fetchedResultsController!.object(at: indexPath) as! Tag
		
		cell.backgroundColor = tableCellBackgroundColor
		cell.textLabel?.textColor = tableCellTextColor
		cell.textLabel!.text = tag.text
		
		return cell
	}
	
	//allow deletion
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	//handle deletion
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if (editingStyle == .delete) {
			//remove tag from main context
			let tag = fetchedResultsController!.object(at: indexPath) as! Tag
			CoreDataStack.instance.context.delete(tag)
			CoreDataStack.instance.save()
			
			//remove tag from table view
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	// MARK: UITableViewDelegate
	
	//go to collage for tag on row tap
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tag = fetchedResultsController!.object(at: indexPath) as! Tag
		performSegue(withIdentifier: collageSegueIdentifier, sender: tag)
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TagViewController: NSFetchedResultsControllerDelegate {
	
	func performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch let e as NSError {
			print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
		}
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tagTableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange sectionInfo: NSFetchedResultsSectionInfo,
					atSectionIndex sectionIndex: Int,
					for type: NSFetchedResultsChangeType) {
		
		let set = IndexSet(integer: sectionIndex)
		
		switch (type) {
		case .insert:
			tagTableView.insertSections(set, with: .automatic)
		case .delete:
			tagTableView.deleteSections(set, with: .automatic)
		default:
			print("This message should never be seen.")
			break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		
		switch(type) {
		case .insert:
			tagTableView.insertRows(at: [newIndexPath!], with: .fade)
		case .delete:
			tagTableView.deleteRows(at: [indexPath!], with: .fade)
		case .update:
			tagTableView.reloadRows(at: [indexPath!], with: .fade)
		case .move:
			tagTableView.deleteRows(at: [indexPath!], with: .fade)
			tagTableView.insertRows(at: [newIndexPath!], with: .fade)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tagTableView.endUpdates()
	}
}
