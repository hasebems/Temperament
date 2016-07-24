//
//  HSBSmNote.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/05/28.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import UIKit

//============================================================
let tPosKeyOfs: [CGFloat] = [
	//	調による音符のオフセット位置
	50,40,30,20,10,5,0,0,0,5,10,20,30,40,50
]
//============================================================
let tPosNote: [CGPoint] = [
	//	全音符の座標
	CGPoint(x:150,y:138),CGPoint(x:150,y:128),CGPoint(x:150,y:118),CGPoint(x:150,y:108),
	CGPoint(x:150,y:98),CGPoint(x:150,y:88),CGPoint(x:150,y:78),CGPoint(x:150,y:68),
	CGPoint(x:150,y:58),CGPoint(x:150,y:48),CGPoint(x:150,y:38),CGPoint(x:150,y:28),
	CGPoint(x:150,y:18),CGPoint(x:150,y:8)
]
//============================================================
let tMarkAdjust: [CGPoint] = [
	//	各臨時記号の座標調整値
	//	x:大きいほど左に  y:大きいほど上に、
	CGPoint(x:0,y:0),	CGPoint(x:17,y:9),	CGPoint(x:17,y:13), CGPoint(x:17,y:-3), CGPoint(x:24,y:13), CGPoint(x:12,y:9)
	// 					sharp				flat				double sharp		double flat, 		natural
]

//----------------------------------------------------------------
//				Define HSBSmNote Class
//----------------------------------------------------------------
class HSBSmNote {
	
	let NOTE_LINE_LENGTH:CGFloat =		57
	let GAP_SERIAL_NOTE:CGFloat =		30
	let GAP_ACCI_SIZE:CGFloat =			16
	let KEY_NOTE_SIZE: CGFloat = 		0.54
	
	//========================================================
	enum TmpMark: Int {
		case NOTHING = 0
		case SHARP
		case FLAT
		case DOUBLE_SHARP
		case DOUBLE_FLAT
		case NATURAL
	}
	//------------------------------------------------------------
	//				Variable
	//------------------------------------------------------------
	var position: Int = 0			//	[Get]
	var rightOfs: Int = 0			//	[Set/Get]	0:nothing, 1:right
	var acciState: Int = 0			//	[Get]	-1:down, 0:no acci, 1:up
	var acciRightOfs: Int = 0		//	[Set/Get]	臨時記号による右側オフセット	0〜MAX_ACCI_RIGHT_OFS-1

	private var parent: HSBSheetmusic? = nil
	private var noteImage: UIImageView? = nil
	private var acciImage: UIImageView? = nil
	
	private var orgx: CGFloat = 0			//	determine when display
	private var orgy: CGFloat = 0			//	determine when init
	private var dispPosition: Int = 0		//	determine when init
	var originalNote: Int = -1				//	determine when init
	var externalCounter: Int = 1					//	determine when init
	
	//------------------------------------------------------------
	//				Initializer
	//------------------------------------------------------------
	init( pt:HSBSheetmusic, pstn:Int, orgNt:Int ) {
		parent = pt
		position = pstn
		originalNote = orgNt
		
		if pstn >= CENTER_NOTE_NUMBER {
			dispPosition = pstn - CENTER_NOTE_NUMBER
			orgy = 0
		}
		else {
			dispPosition = pstn
			orgy = VIEW_HEIGHT
		}
	}
	//------------------------------------------------------------
	//		音符をノート位置から表示(へ音記号の一番下の位置=0、真ん中の位置=12)
	//		upOrDown	-1:down, 0:nothing, 1:up
	//------------------------------------------------------------
	func placeNote( upOrDown: Int, gap: Int ){
		
		if ( noteImage != nil ) { return }
		
		//	set variables
		acciState = upOrDown
		rightOfs = gap

		if let par = parent {
			orgx = CGFloat(par.currentViewNum/2)*VIEW_WIDTH
		}
			
		//	display a note
		displayWholeNote()
			
		//	Display Accidentals
		displayAcci()
	}
	//------------------------------------------------------------
	//				Erace a note
	//------------------------------------------------------------
	func eraseNote() {
		
		rightOfs = 0
		acciState = 0
		acciRightOfs = 0

		//	remove a note
		if let ni = noteImage {
			ni.removeFromSuperview()
			noteImage = nil
		}
		
		//	remove accidental mark
		if let ai = acciImage {
			ai.removeFromSuperview()
			acciImage = nil
		}
	}
	//------------------------------------------------------------
	//				Update Display
	//------------------------------------------------------------
	func updateNoteRightGap( gap: Int ) {
	
		if let ni = noteImage {

			if ( gap == rightOfs ){ return }
			rightOfs = gap;
	
			ni.removeFromSuperview()
	
			//	Display a note
			displayWholeNote()
		}
	}
	//--------------------------------------------------------
	func updateAcciRightOfs() {

		if let ai = acciImage {
			ai.removeFromSuperview()
			
			//	Display Accidentals
			displayAcci()
		}
	}
	//------------------------------------------------------------
	//				Decide Tmp Mark
	//------------------------------------------------------------
	private func decideTmpMark( doremi:Int, upOrDown: Int,  key:Int ) -> TmpMark {
		
		var tpP: TmpMark = .NOTHING
		if let par = parent {
			let tmp: Int = par.tKeySignature[key][doremi]
			
			switch ( tmp ){
			case -1:
				if ( upOrDown > 0 ){ tpP = .NATURAL }
				else { tpP = .DOUBLE_FLAT }
			case 0:
				if ( upOrDown > 0 ){ tpP = .SHARP }
				else { tpP = .FLAT }
			case 1:
				if ( upOrDown > 0 ){ tpP = .DOUBLE_SHARP }
				else { tpP = .NATURAL }
			default: break
			}
		}
		return tpP
	}
	//------------------------------------------------------------
	//			Display a note
	//------------------------------------------------------------
	private func displayWholeNote() {
		var x,y,w,h: CGFloat
		var rightAdjust: CGFloat
		
		if let par = parent {
			
			if ( rightOfs != 0 ){
				rightAdjust = GAP_SERIAL_NOTE
			}
			else {
				rightAdjust = 0
			}
			
			let img: UIImage = UIImage(named: "totalnote.png")!
			x = orgx + tPosNote[dispPosition].x + tPosKeyOfs[par.currentViewNum/2] + rightAdjust
			y = orgy + tPosNote[dispPosition].y
			w = img.size.width*KEY_NOTE_SIZE
			h = img.size.height*KEY_NOTE_SIZE
			
			noteImage = UIImageView(frame: CGRectMake(x,y,w,h))
			if let ni = noteImage {
				ni.image = img
				par.addSubview(ni)
			}
		}
	}
	//------------------------------------------------------------
	//			Display Accidental
	//------------------------------------------------------------
	private func displayAcci() {
		var x,y,w,h: CGFloat
		
		if let par = parent {
			var tpP: TmpMark = .NOTHING
			if ( acciState != 0 ){
				var doremi: Int
				if ( par.currentViewNum%2 == 1 ){
					doremi = (dispPosition+2)%7
				}
				else {
					doremi = dispPosition%7;
				}
				tpP = decideTmpMark( doremi, upOrDown:acciState, key:(par.currentViewNum)/2 )
			}
			
			var imgA: UIImage
			var index: Int = 0
			switch (tpP) {
			case .SHARP:		imgA = UIImage(named: "sharp.png")!;		index = 1
			case .FLAT:			imgA = UIImage(named: "flat.png")!;			index = 2
			case .DOUBLE_SHARP:	imgA = UIImage(named: "doublesharp.png")!;	index = 3
			case .DOUBLE_FLAT:	imgA = UIImage(named: "doubleflat.png")!;	index = 4
			case .NATURAL:		imgA = UIImage(named: "natural.png")!;		index = 5
			default: return
			}
			
			let gap: CGFloat = CGFloat(acciRightOfs)*GAP_ACCI_SIZE
			x = orgx + tPosNote[dispPosition].x - tMarkAdjust[index].x + tPosKeyOfs[par.currentViewNum/2] - gap
			y = orgy + tPosNote[dispPosition].y - tMarkAdjust[index].y
			w = imgA.size.width*par.KEY_MARK_SIZE
			h = imgA.size.height*par.KEY_MARK_SIZE
			acciImage = UIImageView(frame: CGRectMake(x,y,w,h))
			if let ai = acciImage {
				ai.image = imgA
				par.addSubview(ai)
			}
		}
	}
}


