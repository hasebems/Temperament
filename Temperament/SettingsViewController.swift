//
//  SettingsViewController.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/07/02.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import UIKit

//----------------------------------------------------------------
//				Define HSBSheetmusic Class
//----------------------------------------------------------------
class SettingsViewController: UIViewController {

//------------------------------------------------------------
//				Define const numbers
//------------------------------------------------------------
	let MAX_SOLFA_NUMBER = 12
	let TOTAL_TUNING_DISPLAY = 12

//------------------------------------------------------------
//				Variables
//------------------------------------------------------------
	@IBOutlet weak var c_cent: UILabel!
	@IBOutlet weak var cs_cent: UILabel!
	@IBOutlet weak var d_cent: UILabel!
	@IBOutlet weak var ds_cent: UILabel!
	@IBOutlet weak var e_cent: UILabel!
	@IBOutlet weak var f_cent: UILabel!
	@IBOutlet weak var fs_cent: UILabel!
	@IBOutlet weak var g_cent: UILabel!
	@IBOutlet weak var gs_cent: UILabel!
	@IBOutlet weak var a_cent: UILabel!
	@IBOutlet weak var as_cent: UILabel!
	@IBOutlet weak var b_cent: UILabel!
	@IBOutlet weak var tuning: UILabel!

	@IBOutlet weak var c_centStepper: UIStepper!
	@IBOutlet weak var cs_centStepper: UIStepper!
	@IBOutlet weak var d_centStepper: UIStepper!
	@IBOutlet weak var ds_centStepper: UIStepper!
	@IBOutlet weak var e_centStepper: UIStepper!
	@IBOutlet weak var f_centStepper: UIStepper!
	@IBOutlet weak var fs_centStepper: UIStepper!
	@IBOutlet weak var g_centStepper: UIStepper!
	@IBOutlet weak var gs_centStepper: UIStepper!
	@IBOutlet weak var a_centStepper: UIStepper!
	@IBOutlet weak var as_centStepper: UIStepper!
	@IBOutlet weak var b_centStepper: UIStepper!
	@IBOutlet weak var tuningStepper: UIStepper!

	var totalTuning:Double = 440.0
	var eachNoteTune:[Double] = [0,100,200,300,400,500,600,700,800,900,1000,1100]
	
	//------------------------------------------------------------
	//				View did load
	//------------------------------------------------------------
	override func viewDidLoad() {

		c_centStepper.value = eachNoteTune[0]
		cs_centStepper.value = eachNoteTune[1]
		d_centStepper.value = eachNoteTune[2]
		ds_centStepper.value = eachNoteTune[3]
		e_centStepper.value = eachNoteTune[4]
		f_centStepper.value = eachNoteTune[5]
		fs_centStepper.value = eachNoteTune[6]
		g_centStepper.value = eachNoteTune[7]
		gs_centStepper.value = eachNoteTune[8]
		a_centStepper.value = eachNoteTune[9]
		as_centStepper.value = eachNoteTune[10]
		b_centStepper.value = eachNoteTune[11]
		tuningStepper.value = totalTuning
		
		for var cnt=0; cnt<MAX_SOLFA_NUMBER; cnt++ {
			updateValueDisplay(cnt, stepValue: eachNoteTune[cnt])
		}
		updateValueDisplay(TOTAL_TUNING_DISPLAY, stepValue: totalTuning)
	}
	//------------------------------------------------------------
	//				View Receive Memory Warning
	//------------------------------------------------------------
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	//------------------------------------------------------------
	//				Prepare for Segue 
	//------------------------------------------------------------
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		//	Send present Custom/Total tuning value to Setting View
		if (segue.identifier == "returnToMainSegue") {
			var mainView : ViewController = segue.destinationViewController as! ViewController
			for var cnt=0; cnt<12; cnt++ {
				mainView.tg.customCents[cnt] = eachNoteTune[cnt] - Double(cnt)*100
			}
			mainView.tg.changeTune(totalTuning)
		}
	}

	//------------------------------------------------------------
	//				Stepper Event
	//------------------------------------------------------------
	@IBAction func GetStepperEvent(sender: UIStepper) {

		updateValueDisplay(sender.tag, stepValue:sender.value )
	}
	//------------------------------------------------------------
	//				Update Value Display
	//------------------------------------------------------------
	func updateValueDisplay( displayNum:Int, stepValue:Double ) {
		switch displayNum {
		case 0: c_cent.text = String(format: "%.1f", stepValue)
		case 1: cs_cent.text = String(format: "%.1f", stepValue)
		case 2: d_cent.text = String(format: "%.1f", stepValue)
		case 3: ds_cent.text = String(format: "%.1f", stepValue)
		case 4: e_cent.text = String(format: "%.1f", stepValue)
		case 5: f_cent.text = String(format: "%.1f", stepValue)
		case 6: fs_cent.text = String(format: "%.1f", stepValue)
		case 7: g_cent.text = String(format: "%.1f", stepValue)
		case 8: gs_cent.text = String(format: "%.1f", stepValue)
		case 9: a_cent.text = String(format: "%.1f", stepValue)
		case 10: as_cent.text = String(format: "%.1f", stepValue)
		case 11: b_cent.text = String(format: "%.1f", stepValue)
		case TOTAL_TUNING_DISPLAY:
			tuning.text = String(format: "%.0f", stepValue)
			totalTuning = stepValue
		default:break
		}
		if displayNum < 12 {
			eachNoteTune[displayNum] = stepValue
		}
	}
}