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
	let cellIdentifier = "TagCell"
	
	//MARK: Outlets
	
	@IBOutlet var tagTableView: UITableView!
	@IBOutlet var noTagsLabel: UILabel!
	
	//MARK: Actions
	
	@IBAction func openAddTagDialog() {
		let alert = UIAlertController(title: "Add a tag", message: "", preferredStyle: .alert)
		
		alert.addTextField(configurationHandler: nil)
		
		alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [alert] (_) in
			let textField = alert.textFields![0]
			
			//TODO: Add tag to core data
			
			let tag = Tag(text: textField.text!)
			(UIApplication.shared.delegate as! AppDelegate).tags.append(tag)
			
			self.performSegue(withIdentifier: self.collageSegueIdentifier, sender: tag)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//TODO: load all tags from core data main context into table view
		let tags = (UIApplication.shared.delegate as! AppDelegate).tags
		tagTableView.reloadData()
		tagTableView.isHidden = tags.count == 0
		noTagsLabel.isHidden = tags.count != 0
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

//MARK: UITableViewDelegate and UITableViewDataSource

extension TagViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (UIApplication.shared.delegate as! AppDelegate).tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let tag = (UIApplication.shared.delegate as! AppDelegate).tags[indexPath.row]
		
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
			(UIApplication.shared.delegate as! AppDelegate).tags.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	// MARK: UITableViewDelegate
	
	//go to collage for tag on row tap
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tag = (UIApplication.shared.delegate as! AppDelegate).tags[indexPath.row]
		performSegue(withIdentifier: collageSegueIdentifier, sender: tag)
	}
}
