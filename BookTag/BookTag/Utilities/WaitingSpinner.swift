//
//  WaitingSpinner.swift
//  BookTag
//
//  Created by Jason Wedepohl on 2018/01/17.
//  Copyright © 2018 Jason Wedepohl. All rights reserved.
//

import UIKit

class WaitingSpinner {
	//MARK: Properties
	
	var blurView: UIVisualEffectView? = nil
	var spinnerView: UIActivityIndicatorView? = nil
	
	//MARK: Functions
	
	func show(_ view: UIView) {
		//first add blur view to blur screen contents
		blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		blurView!.frame = view.bounds
		view.addSubview(blurView!)
		
		//then add a spinner in the center
		spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinnerView?.center = view.center
		spinnerView?.startAnimating()
		view.addSubview(spinnerView!)
	}
	
	func hide() {
		if (blurView != nil) {
			blurView!.removeFromSuperview()
			blurView = nil
		}
		
		if (spinnerView != nil) {
			spinnerView!.removeFromSuperview()
			spinnerView = nil
		}
	}
}

