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
class SettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {


	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	@IBOutlet weak var tmprTableView: UITableView!

	fileprivate let mySections: NSArray = ["Total Tuning", "Custom Temperament"]
	
	var initCustomTmpValue = [Double]( repeating: 0.0, count: 12 )
	var initTuning: Double = 0
	var items: [String] = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
	var totalTuneCell: CustomTmprTableViewCell? = nil
	var customTmpCells = [CustomTmprTableViewCell?] ( repeating: nil, count: 12 )

	//------------------------------------------------------------
	//				View did load
	//------------------------------------------------------------
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tmprTableView.delegate = self
		tmprTableView.dataSource = self
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
	override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
		//	Send present Custom/Total tuning value to Setting View
		if (segue.identifier == "returnToMainSegue") {
			let mainView : ViewController = segue.destination as! ViewController
			//	Custom Temperament
			for cnt in 0 ..< 12 {
				var cent = initCustomTmpValue[cnt]
				if let ctCell = customTmpCells[cnt] {
					cent = ctCell.cellValue
				}
				mainView.tg.customCents[cnt] = cent - Double(cnt)*100
			}
			//	Total Tuning
			if let ttCell = totalTuneCell {
				mainView.tg.changeTune(ttCell.cellValue)
			}
			else {
				mainView.tg.changeTune(440)
			}
		}
	}
	//------------------------------------------------------------
	//				Table View
	//------------------------------------------------------------
	func numberOfSections(in tView: UITableView) -> Int {
		return mySections.count
	}
	//------------------------------------------------------------
	func tableView(_ tView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return mySections[section] as? String
	}
	//------------------------------------------------------------
	func tableView(_ tView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTmprTableViewCell
		if indexPath.section == 0 {
			cell.initDisplay(initTuning,title: "",unit:"[Hz]")
			totalTuneCell = cell
		}
		else if indexPath.section == 1 {
			cell.initDisplay(initCustomTmpValue[indexPath.row], title: items[indexPath.row], unit:"[cent]")
			customTmpCells[indexPath.row] = cell

			if indexPath.row == items.count-1 {
				//	Set Scroll view Size when last cell is called
				//	なぜそうなるか分からなかったので、強引にスクロールするように数字を合わせた
				let displayWidth: CGFloat = self.view.frame.width
				let displayHeight: CGFloat = self.view.frame.height
				let originalHeight: CGFloat = tView.contentSize.height
				let scrollHeightDiff: CGFloat = originalHeight - (displayHeight+48)
				tView.contentSize = CGSize(width: displayWidth, height: originalHeight+scrollHeightDiff+132)
			}
		}
		return cell
	}
	//------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else if section == 1 {
			return items.count
		} else {
			return 0
		}
	}
}
