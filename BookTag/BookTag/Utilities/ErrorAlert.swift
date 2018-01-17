//
//  ErrorAlert.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class ErrorAlert {
	static func show(_ controller: UIViewController, _ message: String?) {
		guard message != nil else {
			print("showErrorAlert(): No message to display.")
			return
		}
		
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		controller.present(alert, animated: true, completion: nil)
	}
}

