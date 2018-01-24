//
//  BaseController.swift
//  BookTag
//
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
	
	//MARK: Constants
	
	//keys for UserDefaults
	let valuesExistKey = "ValuesExist"
	let nightModeKey = "NightMode"
	
	let iosDefaultTint = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
	let iosDefaultNavBarColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
	let nightModeBackgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
	let nightModeNavbarColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setNightModeColors()
	}
	
	//MARK: Day/night mode methods
	
	func toggleNightMode() {
		if UserDefaults.standard.bool(forKey: valuesExistKey) {
			if UserDefaults.standard.bool(forKey: nightModeKey) {
				UserDefaults.standard.set(false, forKey: nightModeKey)
			} else {
				UserDefaults.standard.set(true, forKey: nightModeKey)
			}
		} else {
			UserDefaults.standard.set(true, forKey: valuesExistKey)
			UserDefaults.standard.set(false, forKey: nightModeKey)
		}
		UserDefaults.standard.synchronize()
		setNightModeColors()
	}
	
	func setNightModeColors() {
		if UserDefaults.standard.bool(forKey: valuesExistKey) {
			if UserDefaults.standard.bool(forKey: nightModeKey) {
				useNightColors()
			} else {
				useDayColors()
			}
		}
	}
	
	//methods to be overridden by each view controller
	func useDayColors() {
		view.backgroundColor = UIColor.white
		navigationController?.navigationBar.barTintColor = iosDefaultNavBarColor
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : iosDefaultTint]
		UIApplication.shared.statusBarStyle = .default
		navigationController?.navigationBar.tintColor = iosDefaultTint
	}
	
	func useNightColors() {
		view.backgroundColor = nightModeBackgroundColor
		navigationController?.navigationBar.barTintColor = nightModeNavbarColor
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		UIApplication.shared.statusBarStyle = .lightContent
		navigationController?.navigationBar.tintColor = UIColor.white
	}
}
