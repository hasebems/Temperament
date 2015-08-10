//
//  CustomTmprTableViewCell.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/08/05.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import UIKit

class CustomTmprTableViewCell: UITableViewCell {

	//------------------------------------------------------------
	//				Define const numbers
	//------------------------------------------------------------
	let MAX_SOLFA_NUMBER = 12
	let TOTAL_TUNING_DISPLAY = 12

	@IBOutlet weak var tuningStepper: UIStepper!
	@IBOutlet weak var tuningValue: UILabel!
	@IBOutlet weak var tuningTitle: UILabel!
	@IBOutlet weak var unitTitle: UILabel!

	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	var cellValue:Double = 0
	
	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
	
	}

	//------------------------------------------------------------
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	//------------------------------------------------------------
	//				Stepper Event
	//------------------------------------------------------------
	@IBAction func GetStepperEvent(sender: UIStepper) {
		
		tuningValue.text = String(format: "%.0f", sender.value)
		cellValue = sender.value
	}
	//------------------------------------------------------------
	//				Update Value Display
	//------------------------------------------------------------
	func initDisplay( initValue:Double, title:String, unit:String ) {
		cellValue = initValue
		tuningStepper.value = initValue
		unitTitle.text = unit
		tuningTitle.text = title
		tuningValue.text = String(format: "%.0f", cellValue)
	}
}
