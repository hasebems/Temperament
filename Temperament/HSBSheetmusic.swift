//
//  HSBSheetmusic.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/05/23.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import UIKit

//----------------------------------------------------------------
//				Define public const number
//----------------------------------------------------------------
let VIEW_WIDTH:CGFloat =		300
let VIEW_HEIGHT:CGFloat =		180

//	The order is
//	0:Cb G-clef
//	1:Cb F-clef
//	2:Gb G-clef
//	...
let	MAX_KEY_NUM		= 15
let	MAX_CLEF_NUM	= 2
let	MAX_VIEW_NUM	= MAX_KEY_NUM*MAX_CLEF_NUM
let KEY_C			= 14

let	MIN_NOTE_NUMBER				= 0		//	E1
let	CENTER_NOTE_NUMBER			= 12	//	C3
let	MAX_NOTE_NUMBER				= 25	//	B4

//----------------------------------------------------------------
//				Define HSBSheetmusic Class
//----------------------------------------------------------------
class HSBSheetmusic: UIView {

	//------------------------------------------------------------
	//				Define const numbers
	//------------------------------------------------------------
	let ONE_VIEW_WIDTH =				VIEW_WIDTH
	let ONE_VIEW_HEIGHT =				VIEW_HEIGHT
	let MAX_KEY =						MAX_KEY_NUM
	
	let TOTAL_VIEW_WIDTH:CGFloat =		VIEW_WIDTH*CGFloat(MAX_KEY_NUM)
	let TOTAL_VIEW_HEIGHT:CGFloat =		VIEW_HEIGHT*CGFloat(MAX_CLEF_NUM)
	
	let TOP_MARGIN:CGFloat = 			50
	let LEFT_MARGIN:CGFloat =			10
	let LINE_INTERVAL:CGFloat = 		20
	let LINE_WIDTH:CGFloat =			1
	let LINE_LENGTH:CGFloat =			280
	
	//------------------------------------------------------------
	//				Define const tables
	//------------------------------------------------------------
	let tKeyToRoot: [[Int]] = [
		[	0, 4, 1, 5, 2, 6, 3, 0, 4, 1, 5, 2, 6, 3, 0 ],
		[	5, 2, 6, 3, 0, 4, 1, 5, 2, 6, 3, 0, 4, 1, 5 ]
	]
	//============================================================
	let tRootMarkYPosition: [[Int]] = [
		[145,75], [135,65], [125,55], [115,45], [105,35], [95,25], [85,15]
	]
	//============================================================
	let tAccidentPosition: [[[CGPoint]]] = [
	//	coordinates of sharp mark
	[
		[CGPoint(x:80,y:28),	CGPoint(x:80,y:48)],
		[CGPoint(x:93,y:58),	CGPoint(x:93,y:78)],
		[CGPoint(x:106,y:21),	CGPoint(x:106,y:41)],
		[CGPoint(x:119,y:50),	CGPoint(x:119,y:70)],
		[CGPoint(x:132,y:80),	CGPoint(x:132,y:100)],
		[CGPoint(x:145,y:40),	CGPoint(x:145,y:60)],
		[CGPoint(x:158,y:70),	CGPoint(x:158,y:90)]
	],
	//	coordinates of flat mark
	[
		[CGPoint(x:80,y:65),	CGPoint(x:80,y:85)],
		[CGPoint(x:93,y:35),	CGPoint(x:93,y:55)],
		[CGPoint(x:106,y:74),	CGPoint(x:106,y:94)],
		[CGPoint(x:119,y:45),	CGPoint(x:119,y:65)],
		[CGPoint(x:132,y:85),	CGPoint(x:132,y:105)],
		[CGPoint(x:145,y:54),	CGPoint(x:145,y:74)],
		[CGPoint(x:158,y:93),	CGPoint(x:158,y:113)]
	],
	]
	//============================================================
	let tKeySignature: [[Int]] = [
		[-1,-1,-1,-1,-1,-1,-1 ],	//	Cb
		[-1,-1,-1, 0,-1,-1,-1 ],	//	Gb
		[ 0,-1,-1, 0,-1,-1,-1 ],	//	Db
		[ 0,-1,-1, 0, 0,-1,-1 ],	//	Ab
		[ 0, 0,-1, 0, 0,-1,-1 ],	//	Eb
		[ 0, 0,-1, 0, 0, 0,-1 ],	//	Bb
		[ 0, 0, 0, 0, 0, 0,-1 ],	//	F
	
		[ 0, 0, 0, 0, 0, 0, 0 ],	//	C
	
		[ 0, 0, 0, 1, 0, 0, 0 ],	//	G
		[ 1, 0, 0, 1, 0, 0, 0 ],	//	D
		[ 1, 0, 0, 1, 1, 0, 0 ],	//	A
		[ 1, 1, 0, 1, 1, 0, 0 ],	//	E
		[ 1, 1, 0, 1, 1, 1, 0 ],	//	B
		[ 1, 1, 1, 1, 1, 1, 0 ],	//	F#
		[ 1, 1, 1, 1, 1, 1, 1 ]		//	C#
	]

	//------------------------------------------------------------
	//				Variable
	//------------------------------------------------------------
	var acciInputMode: Int = 0			//	-1:down 0:no change 1:up
	var currentViewNum: Int = KEY_C		//	0 - 29 ( MAX_VIEW_NUM-1 )
	var noteList = [HSBSmNote]()
	var maxAcciRightOfs: Int = 0		//	Max rightside Offset by Accidental Mark
	
	//------------------------------------------------------------
	//				Initilizer
	//------------------------------------------------------------
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	//------------------------------------------------------------	
	override init(frame: CGRect) {
		super.init(frame: CGRectMake(0, 0, TOTAL_VIEW_WIDTH, TOTAL_VIEW_HEIGHT))
	}
	//------------------------------------------------------------
	//				Draw Rect
	//------------------------------------------------------------
	// Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		let _ctxt:CGContextRef = UIGraphicsGetCurrentContext()
		
		for i in 0..<MAX_VIEW_NUM {
			drawOneKeyLine( i, _ctxt: _ctxt )
		}
	}
	//------------------------------------------------------------
	//				Draw Lines for One Key
	//------------------------------------------------------------
	func drawOneKeyLine( view:Int, _ctxt:CGContextRef ) {

		let orgx:CGFloat = CGFloat(view/2)*ONE_VIEW_WIDTH
		let orgy:CGFloat = CGFloat(view%2)*ONE_VIEW_HEIGHT
		
		//	paint white
		CGContextSetRGBStrokeColor(_ctxt,0,0,0,1)
		CGContextSetRGBFillColor(_ctxt, 1.0, 1.0, 1.0, 1.0)
		CGContextFillRect(_ctxt, CGRectMake(orgx, orgy, ONE_VIEW_WIDTH, ONE_VIEW_HEIGHT))
		
		//	draw five lines
		CGContextSetLineWidth(_ctxt,CGFloat(LINE_WIDTH))
		for i in 0...4 {
			CGContextMoveToPoint(_ctxt, orgx+LEFT_MARGIN, orgy+TOP_MARGIN+LINE_INTERVAL*CGFloat(i) )
			CGContextAddLineToPoint(_ctxt, orgx+LEFT_MARGIN+LINE_LENGTH, orgy+TOP_MARGIN+LINE_INTERVAL*CGFloat(i))
			CGContextStrokePath(_ctxt)
		}

		//	red mark that indicates Do
		CGContextSetRGBStrokeColor(_ctxt,1,0,0,1);
		CGContextSetLineWidth(_ctxt,LINE_WIDTH);
		for j in 0...1 {
			let y = CGFloat(tRootMarkYPosition[tKeyToRoot[view%2][view/2]][j])
			for k in 0...5 {
				let kx = CGFloat(k)
				CGContextMoveToPoint(_ctxt, orgx+2+kx, orgy+y+kx )
				CGContextAddLineToPoint(_ctxt, orgx+2+kx, orgy+y+10-kx )
				CGContextStrokePath(_ctxt)
			}
		}		
	}
	//------------------------------------------------------------
	//				Draw All Marks for All keys
	//------------------------------------------------------------
	let	G_CLEF_X_OFS:CGFloat =		17
	let	G_CLEF_Y_OFS:CGFloat =		9
	let	G_CLEF_X_SZ:CGFloat =		63
	let	G_CLEF_Y_SZ:CGFloat =		153

	let	F_CLEF_X_OFS:CGFloat =		12
	let	F_CLEF_Y_OFS:CGFloat =		46
	let	F_CLEF_X_SZ:CGFloat =		68
	let	F_CLEF_Y_SZ:CGFloat =		72

	let KEY_MARK_SIZE:CGFloat =		0.4
	//------------------------------------------------------------
	func drawKey( sharpOrFlat:Int, key:Int, cnt:Int, mark:UIImage ) {

		let w = mark.size.width
		let h = mark.size.height

		for var i=0; i<cnt; i++ {
			for j in 0...1 {
				let keyView: UIImageView =
					UIImageView(frame: CGRectMake(tAccidentPosition[sharpOrFlat][i][j].x + (CGFloat(key)*ONE_VIEW_WIDTH),
						tAccidentPosition[sharpOrFlat][i][j].y + (CGFloat(j)*ONE_VIEW_HEIGHT),
						w*KEY_MARK_SIZE,
						h*KEY_MARK_SIZE))
				keyView.image = mark
				addSubview(keyView)
			}
		}
	}
	//------------------------------------------------------------
	func drawAllKey() {

		for var j=0; j<MAX_KEY_NUM; j++ {
			var keyNumber:Int = j-MAX_KEY_NUM/2
			if ( keyNumber > 0 ){
				let mark:UIImage = UIImage(named: "sharp.png")!
				drawKey( 0, key: j, cnt:keyNumber, mark: mark )
			}
			else if ( keyNumber < 0 ){
				let mark:UIImage = UIImage(named: "flat.png")!
				drawKey( 1, key: j, cnt:-keyNumber, mark: mark )
			}
			
			//	Draw G-clef
			let gclef: UIImageView = UIImageView(frame: CGRectMake(CGFloat(j)*ONE_VIEW_WIDTH+G_CLEF_X_OFS,
				G_CLEF_Y_OFS,G_CLEF_X_SZ,G_CLEF_Y_SZ))
			gclef.image = UIImage(named: "gclef.png")
			addSubview(gclef)

			//	Draw F-clef
			let fclef: UIImageView = UIImageView(frame: CGRectMake(CGFloat(j)*ONE_VIEW_WIDTH+F_CLEF_X_OFS,
				ONE_VIEW_HEIGHT+F_CLEF_Y_OFS,F_CLEF_X_SZ,F_CLEF_Y_SZ))
			fclef.image = UIImage(named: "fclef.png")
			addSubview(fclef)
		}

		setNeedsDisplay()
	}
	//------------------------------------------------------------
	//				Manage to draw Note
	//------------------------------------------------------------
	func manageNote( position:Int ){
		
		//	find same position note
		for (idx,nt) in enumerate(noteList) {
			if nt.position == position {
				//	Erace & Note Off
				nt.eraseNote()
				noteList.removeAtIndex(idx)
				return
			}
		}

		//	Place & Note On
		let newNt = HSBSmNote(pt: self, pstn: position)
		noteList.append( newNt )
		newNt.placeNote(acciInputMode)
	}
	//------------------------------------------------------------
	//				Decide Note Number
	//------------------------------------------------------------
	let	ADJUST_FIRST_POSITION:CGFloat	= 5
	let	INTERVAL:CGFloat				= 10
	let MAX_NOTE_POSITION				= 13
	//------------------------------------------------------------
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		
		let touch = touches.first as! UITouch
		let loc = touch.locationInView(self)
		var position:Int
		var ofsHeight:CGFloat = 0

		if ( currentViewNum%2 != 0 ){
			ofsHeight = VIEW_HEIGHT
		}

		//	analize note position
		position = MAX_NOTE_POSITION+2 - Int(((loc.y - ofsHeight + ADJUST_FIRST_POSITION) / INTERVAL))
		if ( position < 0 ){
			position = 0
		}
		else if ( position > MAX_NOTE_POSITION ){
			position = MAX_NOTE_POSITION
		}
		
		if ( currentViewNum%2 == 0 ){
			position += CENTER_NOTE_NUMBER
		}
		else if ( position > MAX_NOTE_POSITION-2 ){
			//	for C3,D3 of F-clef
			position = MAX_NOTE_POSITION-2
		}

		println( position )
		manageNote( position )
	}
}

