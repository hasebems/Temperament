//
//  ViewController.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/05/23.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import UIKit

//----------------------------------------------------------------
//				Define HSBSheetmusic Class
//----------------------------------------------------------------
class ViewController: UIViewController, UIScrollViewDelegate {

	//------------------------------------------------------------
	//				Define const numbers
	//------------------------------------------------------------
	let PAGE_NONE = -1

	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	@IBOutlet weak var smView: HSBScrollViewWithTouch!
	@IBOutlet weak var swAcci: UISegmentedControl!
	
	var smusic: HSBSheetmusic!

	var crntKey: Int  = 0			//	-7 - 0 - 7
	var isScrolling: Bool = false
	
	//------------------------------------------------------------
	//				View did load
	//------------------------------------------------------------
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		smusic = HSBSheetmusic()
		smusic.drawAllKey()
		smView.addSubview(smusic)

		smView.contentSize = CGSizeMake(smusic.TOTAL_VIEW_WIDTH,smusic.TOTAL_VIEW_HEIGHT)
		smView.clipsToBounds = true
		smView.scrollEnabled = true
		smView.pagingEnabled = true
	 	smView.directionalLockEnabled = true
		smView.alwaysBounceVertical = true
		smView.alwaysBounceHorizontal = true
	 
		 //	Display C major
		smView.scrollRectToVisible(CGRectMake(	smusic.ONE_VIEW_WIDTH*CGFloat(smusic.MAX_KEY/2),0,
												smusic.ONE_VIEW_WIDTH,smusic.ONE_VIEW_HEIGHT), animated: false)
	 	smView.delegate = self	//	add 2015.5.21
		swAcci.selectedSegmentIndex = 1
	}

	//------------------------------------------------------------
	//				Switch Accidental Mode
	//------------------------------------------------------------
	@IBAction func switchAccidental(sender: UISegmentedControl) {
		smusic.acciInputMode = sender.selectedSegmentIndex - 1
	}

	//------------------------------------------------------------
	//				View Receive Memory Warning
	//------------------------------------------------------------
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	//------------------------------------------------------------
	//				called when scroll end
	//------------------------------------------------------------
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		isScrolling = true
	}
	//------------------------------------------------------------
	func scrollViewDidEndDecelerating( sender:UIScrollView ){
		let xcd = sender.contentOffset.x;
		let ycd = sender.contentOffset.y;
		
		if (( xcd%smusic.ONE_VIEW_WIDTH == 0 ) && ( ycd%smusic.ONE_VIEW_HEIGHT == 0 )){
			var crntPage = Int((xcd/smusic.ONE_VIEW_WIDTH)*2 + ycd/smusic.ONE_VIEW_HEIGHT);
			smusic.currentViewNum = crntPage;
			if ( crntPage >= KEY_C ){
				crntKey = (crntPage - KEY_C)/2;
			}
			else {
				crntKey = (crntPage - KEY_C - 1)/2;
			}
			//[self displayKeyName];
		}
		isScrolling = false
	}

}

