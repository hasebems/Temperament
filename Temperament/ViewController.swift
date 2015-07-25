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
class ViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDelegate {

	//------------------------------------------------------------
	//				Define const numbers
	//------------------------------------------------------------
	let PAGE_NONE = -1

	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	@IBOutlet weak var smView: HSBScrollViewWithTouch!
	@IBOutlet weak var swAcci: UISegmentedControl!
	
	@IBOutlet weak var keyName: UILabel!
	@IBOutlet weak var inputNote: UILabel!
	@IBOutlet weak var hzNumber: UILabel!
	@IBOutlet weak var centNumber: UILabel!
	@IBOutlet weak var temperamentSelect: UIPickerView!

	var smusic: HSBSheetmusic = HSBSheetmusic()
	var tg: TemperamentToneGenerator = TemperamentToneGenerator()

	var crntKey: Int  = 0			//	-7 - 0 - 7
	var isScrolling: Bool = false
	var noteOnCount: Int = 0
	var centMode: Int = 0
	var crntHandle: Int = -1

	//------------------------------------------------------------
	//				Tables
	//------------------------------------------------------------
	let tKeyName = [ "Cb","Gb","Db","Ab","Eb","Bb","F","C","G","D","A","E","B","F#","C#" ]
	let tTemperament = ["Equal Temperament","Pythagorean Wolf:Eb-G#","Pythagorean Wolf:D-A","Just Intonation",
						"1/4 Syntonic Comma(Meantone)","1/5 Syntonic Comma","1/6 Syntonic Comma","1/7 Syntonic Comma",
						"Werkmeister III","Kirnberger(1766)","Kirnberger(1771)","Kirnberger(1779)","Custom"]
	
	//------------------------------------------------------------
	//				View did load
	//------------------------------------------------------------
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
		let keyC: Int = smusic.MAX_KEY/2
		smView.scrollRectToVisible(CGRectMake(	smusic.ONE_VIEW_WIDTH*CGFloat(keyC),0,
												smusic.ONE_VIEW_WIDTH,smusic.ONE_VIEW_HEIGHT), animated: false)
	 	smView.delegate = self	//	add 2015.5.21
		swAcci.selectedSegmentIndex = 1
		keyName.text = tKeyName[keyC]
		inputNote.text = "---"

		//	Tone Generator
		tg.changeKey(0)
		tg.changeTemparament(0)

		//	Set Callback when an event happens on Sheetmusic
		smusic.setCallBacks( {
				position,acci->() in
				self.noteOnCount++
				self.smView.scrollEnabled = false
				let handle = self.tg.keyOn( position, acc: acci )
				self.displayNoteOn(handle)
				self.crntHandle = handle
			},
			noteOffCb: {
				position,acci->() in
				self.noteOnCount--
				if ( self.noteOnCount == 0 ){
					self.smView.scrollEnabled = true
					self.displayAllOff()
					self.crntHandle = -1
				}
				self.tg.keyOff( position )
			}
		)
	}
	//------------------------------------------------------------
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		//	Send present Custom/Total tuning value to Setting View
		if (segue.identifier == "settingViewSegue") {
			var settingView : SettingsViewController = segue.destinationViewController as! SettingsViewController
			for var cnt=0; cnt<12; cnt++ {
				settingView.eachNoteTune[cnt] = tg.customCents[cnt] + Double(cnt)*100
			}
			settingView.totalTuning = tg.totalTuning
			smusic.allNoteClear()
		}
	}
	//------------------------------------------------------------
	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		return 1
	}
	//------------------------------------------------------------
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
		return tTemperament.count
	}
	//------------------------------------------------------------
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!{
		return "\(tTemperament[row])"
	}
	//------------------------------------------------------------
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//	Change Temperament
		tg.changeTemparament(row)
		if crntHandle != -1 {
			displayNoteOn(crntHandle)
		}
		else {
			displayAllOff()
		}
	}
	//------------------------------------------------------------
	//			Display Note Number, Frequency, Cent value
	//------------------------------------------------------------
	func displayNoteOn( handle: Int ){
		inputNote.text = tg.getNoteText(handle)
		hzNumber.text = String(format: "%.2f", tg.getHz(handle))
		centNumber.text = String(format: "%.2f", tg.getCent(handle,cmd: centMode))
	}
	//------------------------------------------------------------
	func displayAllOff(){
		inputNote.text = "---"
		hzNumber.text = "----.--"
		centNumber.text = "----.--"
	}
	//------------------------------------------------------------
	//				Switch Accidental Mode/ All Off
	//------------------------------------------------------------
	@IBAction func switchAccidental(sender: UISegmentedControl) {
		smusic.acciInputMode = sender.selectedSegmentIndex - 1
	}
	//------------------------------------------------------------
	@IBAction func switchCentDispMode(sender: UISegmentedControl) {
		centMode = sender.selectedSegmentIndex
		centNumber.text = "----.--"
	}
	//------------------------------------------------------------
	@IBAction func allOff(sender: UIButton) {
		smusic.allNoteClear()
		displayAllOff()
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
		smusic.inputMute = true
	}
	//------------------------------------------------------------
	func scrollViewDidEndDecelerating( sender:UIScrollView ){
		let xcd = sender.contentOffset.x;
		let ycd = sender.contentOffset.y;
		
		if (( xcd%smusic.ONE_VIEW_WIDTH == 0 ) && ( ycd%smusic.ONE_VIEW_HEIGHT == 0 )){
			var crntPage = Int((xcd/smusic.ONE_VIEW_WIDTH)*2 + ycd/smusic.ONE_VIEW_HEIGHT)
			smusic.currentViewNum = crntPage
			if ( crntPage >= KEY_C ){
				crntKey = (crntPage - KEY_C)/2
			}
			else {
				crntKey = (crntPage - KEY_C - 1)/2
			}
			tg.changeKey(crntKey)
			keyName.text = tKeyName[crntPage/2]
		}
		isScrolling = false
		smusic.inputMute = false
	}

}

