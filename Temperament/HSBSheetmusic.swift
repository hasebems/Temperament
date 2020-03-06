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
let VIEW_WIDTH:CGFloat 		= 300
let VIEW_HEIGHT:CGFloat		= 180

//	The order is
//	0:Cb G-clef
//	1:Cb F-clef
//	2:Gb G-clef
//	...
let	MAX_KEY_NUM				= 15
let	MAX_CLEF_NUM			= 2
let	MAX_VIEW_NUM			= MAX_KEY_NUM*MAX_CLEF_NUM
let KEY_C					= 14

let	MIN_NOTE_NUMBER			= 0		//	E1
let	CENTER_NOTE_NUMBER		= 12	//	C3
let	MAX_NOTE_NUMBER			= 25	//	B4

let LEDGER_LINE_BELOW:Int 	= 0
let LEDGER_LINE_ABOVE:Int	= 1
let LEDGER_LINE_MAX:Int 	= 2

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

	let MAX_ACCI_RIGHT_OFS:Int =		4

	//------------------------------------------------------------
	let LINE_NOTHING	= 0
	let LINE_NORM		= 1
	let LINE_RIGHT		= 2
	let LINE_LONG		= 3
	let LINE_STATE_MAX	= 4

	let NOTE_LINE_LENGTH:CGFloat =	57
	let GAP_SERIAL_NOTE:CGFloat	=	30
	
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
		[CGPoint(x:100,y:21),	CGPoint(x:100,y:41)],
		[CGPoint(x:113,y:50),	CGPoint(x:113,y:70)],
		[CGPoint(x:126,y:80),	CGPoint(x:126,y:100)],
		[CGPoint(x:133,y:40),	CGPoint(x:133,y:60)],
		[CGPoint(x:146,y:70),	CGPoint(x:146,y:90)]
	],
	//	coordinates of flat mark
	[
		[CGPoint(x:80,y:65),	CGPoint(x:80,y:85)],
		[CGPoint(x:93,y:35),	CGPoint(x:93,y:55)],
		[CGPoint(x:100,y:74),	CGPoint(x:100,y:94)],
		[CGPoint(x:113,y:45),	CGPoint(x:113,y:65)],
		[CGPoint(x:120,y:85),	CGPoint(x:120,y:105)],
		[CGPoint(x:133,y:54),	CGPoint(x:133,y:74)],
		[CGPoint(x:140,y:93),	CGPoint(x:140,y:113)]
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
	var acciInputMode: Int = 0			//	[Set]	-1:down 0:no change 1:up
	var currentViewNum: Int = KEY_C		//	[Set]	0 - 29 ( MAX_VIEW_NUM-1 )
	var inputMute: Bool = false			//	[Set]	true: Mute, false: available

	fileprivate var ntArray = [HSBSmNote?]( repeating: nil, count: MAX_NOTE_NUMBER+1 )
	fileprivate var ntlineState = [Int]( repeating: 0, count: LEDGER_LINE_MAX )

	//------------------------------------------------------------
	//				Initilizer
	//------------------------------------------------------------
	fileprivate func initVariables() {
		
	}
	//------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initVariables()
	}
	//------------------------------------------------------------	
	override init(frame: CGRect) {
		super.init(frame: CGRect(x: 0, y: 0, width: TOTAL_VIEW_WIDTH, height: TOTAL_VIEW_HEIGHT))
		initVariables()
	}
	//------------------------------------------------------------
	//				Draw Rect
	//------------------------------------------------------------
	// Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		guard let _ctxt:CGContext = UIGraphicsGetCurrentContext() else {
			return
		}
		
		for i in 0..<MAX_VIEW_NUM {
			drawOneKeyLine( i, _ctxt: _ctxt )
		}
	}
	//------------------------------------------------------------
	//				Draw Lines for One Key
	//------------------------------------------------------------
	fileprivate func drawOneKeyLine( _ view:Int, _ctxt:CGContext ) {

		let orgx:CGFloat = CGFloat(view/2)*ONE_VIEW_WIDTH
		let orgy:CGFloat = CGFloat(view%2)*ONE_VIEW_HEIGHT
		
		//	paint white
		_ctxt.setStrokeColor(red: 0,green: 0,blue: 0,alpha: 1)
		_ctxt.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		_ctxt.fill(CGRect(x: orgx, y: orgy, width: ONE_VIEW_WIDTH, height: ONE_VIEW_HEIGHT))
		
		//	draw five lines
		_ctxt.setLineWidth(CGFloat(LINE_WIDTH))
		for i in 0...4 {
			_ctxt.move(to: CGPoint(x: orgx+LEFT_MARGIN, y: orgy+TOP_MARGIN+LINE_INTERVAL*CGFloat(i)))
			_ctxt.addLine(to: CGPoint(x: orgx+LEFT_MARGIN+LINE_LENGTH, y: orgy+TOP_MARGIN+LINE_INTERVAL*CGFloat(i)))
			_ctxt.strokePath()
		}

		//	draw ledger line
		if ( ntlineState[LEDGER_LINE_BELOW] != LINE_NOTHING ){
			_ctxt.setStrokeColor(red: 0,green: 0,blue: 0,alpha: 1);
			let x:CGFloat = tPosNote[0].x + tPosKeyOfs[view/2] - 10
			let y:CGFloat = tPosNote[0].y + 12
			
			_ctxt.move(to: CGPoint(x: orgx+x, y: orgy+y))
			_ctxt.addLine(to: CGPoint(x: orgx+x+57, y: orgy+y))
			_ctxt.strokePath()
		}
		if ( ntlineState[LEDGER_LINE_ABOVE] != LINE_NOTHING ){
			var length:CGFloat = NOTE_LINE_LENGTH
			var rightAdj:CGFloat = 0
			
			switch ( ntlineState[LEDGER_LINE_ABOVE] ){
			case LINE_NORM:
				rightAdj = 0
				length = NOTE_LINE_LENGTH
			case LINE_RIGHT:
				rightAdj = GAP_SERIAL_NOTE
				length = NOTE_LINE_LENGTH
			case LINE_LONG:
				rightAdj = 0
				length = NOTE_LINE_LENGTH + GAP_SERIAL_NOTE
			default: break
			}
			
			_ctxt.setStrokeColor(red: 0,green: 0,blue: 0,alpha: 1)
			let x:CGFloat = tPosNote[12].x + tPosKeyOfs[view/2] - 10 + rightAdj
			let y:CGFloat = tPosNote[12].y + 12
			
			_ctxt.move(to: CGPoint(x: orgx+x, y: orgy+y))
			_ctxt.addLine(to: CGPoint(x: orgx+x+length, y: orgy+y))
			_ctxt.strokePath()
		}
		
		//	red mark that indicates Do
		_ctxt.setStrokeColor(red: 1,green: 0.64,blue: 0,alpha: 1)	// orange
		_ctxt.setLineWidth(LINE_WIDTH)
		for j in 0...1 {
			let y = CGFloat(tRootMarkYPosition[tKeyToRoot[view%2][view/2]][j])
			for k in 0...5 {
				let kx = CGFloat(k)
				_ctxt.move(to: CGPoint(x: orgx+2+kx, y: orgy+y+kx))
				_ctxt.addLine(to: CGPoint(x: orgx+2+kx, y: orgy+y+10-kx))
				_ctxt.strokePath()
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
	fileprivate func drawKey( _ sharpOrFlat:Int, key:Int, cnt:Int, mark:UIImage ) {

		let w = mark.size.width
		let h = mark.size.height

		for i in 0 ..< cnt {
			for j in 0...1 {
				let keyView: UIImageView =
					UIImageView(frame: CGRect(x: tAccidentPosition[sharpOrFlat][i][j].x + (CGFloat(key)*ONE_VIEW_WIDTH),
						y: tAccidentPosition[sharpOrFlat][i][j].y + (CGFloat(j)*ONE_VIEW_HEIGHT),
						width: w*KEY_MARK_SIZE,
						height: h*KEY_MARK_SIZE))
				keyView.image = mark
				addSubview(keyView)
			}
		}
	}
	//------------------------------------------------------------
	func drawAllKey() {

		for j in 0 ..< MAX_KEY_NUM {
			let keyNumber:Int = j-MAX_KEY_NUM/2
			if ( keyNumber > 0 ){
				let mark:UIImage = UIImage(named: "sharp.png")!
				drawKey( 0, key: j, cnt:keyNumber, mark: mark )
			}
			else if ( keyNumber < 0 ){
				let mark:UIImage = UIImage(named: "flat.png")!
				drawKey( 1, key: j, cnt:-keyNumber, mark: mark )
			}
			
			//	Draw G-clef
			let gclef: UIImageView = UIImageView(frame: CGRect(x: CGFloat(j)*ONE_VIEW_WIDTH+G_CLEF_X_OFS,
				y: G_CLEF_Y_OFS,width: G_CLEF_X_SZ,height: G_CLEF_Y_SZ))
			gclef.image = UIImage(named: "gclef.png")
			addSubview(gclef)

			//	Draw F-clef
			let fclef: UIImageView = UIImageView(frame: CGRect(x: CGFloat(j)*ONE_VIEW_WIDTH+F_CLEF_X_OFS,
				y: ONE_VIEW_HEIGHT+F_CLEF_Y_OFS,width: F_CLEF_X_SZ,height: F_CLEF_Y_SZ))
			fclef.image = UIImage(named: "fclef.png")
			addSubview(fclef)
		}

		setNeedsDisplay()
	}
	//------------------------------------------------------------
	//				Set Callback
	//------------------------------------------------------------
	typealias NoteFunc = (Int,Int) -> ()
	fileprivate var noteOnFunc: NoteFunc?
	fileprivate var noteOffFunc: NoteFunc?
	//------------------------------------------------------------
	func setCallBacks( _ noteOnCb: @escaping NoteFunc , noteOffCb: @escaping NoteFunc ) {
		noteOnFunc = noteOnCb
		noteOffFunc = noteOffCb
	}
	//------------------------------------------------------------
	//				All Note Clear
	//------------------------------------------------------------
	func allNoteClear() {
		
		for i in 0 ..< (MAX_NOTE_NUMBER+1) {
			if let nt = ntArray[i] {
				if let noffunc = noteOffFunc {
					noffunc(i, nt.acciState)
				}
				eraseNote(nt)
			}
			ntArray[i] = nil
		}
		//	Check ledger line
		checkNoteLine()
	}
	//------------------------------------------------------------
	//				Touch Event
	//------------------------------------------------------------
	let	ADJUST_FIRST_POSITION:CGFloat	= 5
	let	INTERVAL:CGFloat				= 10
	let MAX_NOTE_POSITION				= 13
	//------------------------------------------------------------
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		guard let touch = touches.first else {
			return
		}
		guard inputMute == false else {
			return
		}

		let loc = touch.location(in: self)
		var position:Int
		var ofsHeight:CGFloat = 0
		
		if ( currentViewNum%2 != 0 ){
			ofsHeight = VIEW_HEIGHT
		}

		//	analyze note position
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

		print( position )
		manageNote( position )
	}
	//------------------------------------------------------------
	//				Receice MIDI Event
	//------------------------------------------------------------
	let tMidiToPosition: [[Int]] = [
		//	-16 means non-display (evenif adding 3, it's a minus value)
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [0,-1],
		[0,0], [1,0], [1,1], [2,0], [2,1], [3,0], [4,-1], [4,0],
		[5,0], [5,1], [6,0], [7,-1], [7,0], [8,0], [8,1], [9,0],
		[9,1], [10,0], [11,-1], [11,0], [12,0], [12,1], [13,0], [14,-1],
		
		[14,0], [15,0], [15,1], [16,0], [16,1], [17,0], [18,-1], [18,0],
		[19,0], [19,1], [20,0], [21,-1], [21,0], [22,0], [22,1], [23,0],
		[23,1], [24,0], [25,-1], [25,0], [26,0], [26,1], [27,0], [28,-1],
		[28,0], [29,0], [29,1], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0],
		[-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0], [-16,0]
	]
	let tOffsetPositionByKey:[Int] = [
		0,-3,1,-2,2,-1,3,0,-3,1,-2,2,-1,3,0
	]
	//------------------------------------------------------------
	func midiNoteOn( _ noteNum: Int ){
		let position: Int = tMidiToPosition[noteNum][0] + tOffsetPositionByKey[currentViewNum/2]
		acciInputMode = tMidiToPosition[noteNum][1]
		var sameNoteCounter = 0;

		//	check limitation
		if position > MAX_NOTE_NUMBER || position < 0 {
			return
		}

		if let nt = ntArray[position] {
			sameNoteCounter = nt.externalCounter
			eraseNote(nt)
		}

		let newNt:HSBSmNote = HSBSmNote(pt: self, pstn: position, orgNt: noteNum)
		newNt.externalCounter = sameNoteCounter+1
		ntArray[position] = newNt
		drawNote(position, newNt: newNt)
	}
	//------------------------------------------------------------
	func midiNoteOff( _ noteNum: Int ){
		let position: Int = tMidiToPosition[noteNum][0] + tOffsetPositionByKey[currentViewNum/2]

		//	check limitation
		if position > MAX_NOTE_NUMBER || position < 0 {
			return
		}
		
		if let nt = ntArray[position] {
			if nt.externalCounter > 1 {
				//	if multiple same note number
				nt.externalCounter = nt.externalCounter - 1
				return
			}
			
			if nt.originalNote == noteNum {
				ntArray[position] = nil
				eraseNote(nt)
			}
		}
	}
	//------------------------------------------------------------
	//				Manage to draw Note
	//------------------------------------------------------------
	fileprivate func manageNote( _ position:Int ){

		if let nt = ntArray[position] {
			if let noffunc = noteOffFunc {
				noffunc( position, nt.acciState )
			}
			ntArray[position] = nil
			eraseNote(nt)
		}
		else {
			let newNt:HSBSmNote = HSBSmNote(pt: self, pstn: position, orgNt: 0)
			ntArray[position] = newNt
			drawNote(position, newNt: newNt)
			if let nonfunc = noteOnFunc {
				nonfunc( position, acciInputMode )
			}
		}
	}
	//------------------------------------------------------------
	//				Draw Note & Adjust location
	//------------------------------------------------------------
	fileprivate func drawNote( _ notePosition:Int, newNt:HSBSmNote ) {

		/*	Right side offset calculation by accidental 	*/
		newNt.acciState = acciInputMode
		if ( calcAcciRightOfs() == true ){
			for i in 0 ..< (MAX_NOTE_NUMBER+1) {
				//	slide all notes and accidentals displayed
				if let ntlp = ntArray[i] {
					if ntlp.acciState != 0 {
						ntlp.updateAcciRightOfs()
					}
				}
			}
		}
		
		//	今押した音符より連続して最も下にある音符を検索
		var first: Int = 0
		if ( notePosition != MIN_NOTE_NUMBER ){
			var cnt = notePosition-1;
			var ntlp = ntArray[cnt]
			while ( ntlp != nil ){
				cnt -= 1
				if ( cnt < MIN_NOTE_NUMBER ){ break }
				ntlp = ntArray[cnt]
			}
			first = cnt+1
		}
		
		//	今押した音符より下の隣り合う音符の位置をずらす
		for  j in first ..< notePosition {
			let right = (j-first)%2
			if let nt = ntArray[j] {
				nt.updateNoteRightGap(right)
			}
		}

		//	Display Note
		let right = (notePosition-first)%2
		newNt.placeNote(acciInputMode, gap: right)

		//	今押した音符より上の隣り合う音符の位置をずらす
		if ( notePosition != MAX_NOTE_NUMBER ){
			var cnt = notePosition+1
			var ntlp = ntArray[cnt]
			while ( ntlp != nil ){
				if let nt = ntlp {
					let right = (cnt-first)%2
					nt.updateNoteRightGap(right)
				}
				cnt += 1
				if ( cnt > MAX_NOTE_NUMBER ){ break }
				ntlp = ntArray[cnt]
			}
		}
		//	加線のチェック
		checkNoteLine()
	}
	//------------------------------------------------------------
	//				Erace Note & Adjust location
	//------------------------------------------------------------
	fileprivate func eraseNote( _ note: HSBSmNote ){

		let notePosition = note.position
	
		//	臨時記号による右側オフセット計算
		note.acciState = 0;
		let stk = calcAcciRightOfs()
			
		//	今押した音符を消す
		note.eraseNote()
			
		//	表示されている全部の音符（臨時記号）を横にずらす
		if ( stk == true ){
			for  i in 0 ..< (MAX_NOTE_NUMBER+1) {
				//	表示されている全部の音符（臨時記号）を横にずらす
				if let ntlp = ntArray[i] {
					if ( ntlp.acciState != 0 ){
						ntlp.updateAcciRightOfs()
					}
				}
			}
		}
			
		//	今押した鍵盤より上の隣り合う音符の位置をずらす
		if ( notePosition != MAX_NOTE_NUMBER ){
			var cnt = notePosition+1
			let first = cnt
			var ntlp = ntArray[cnt]
			while ( ntlp != nil ){
				let right = (cnt-first)%2
				if let nt = ntlp {
					nt.updateNoteRightGap(right)
				}
				cnt += 1
				if ( cnt > MAX_NOTE_NUMBER ){ break }
				ntlp = ntArray[cnt]
			}
		}
		//	Check ledger line
		checkNoteLine()
	}
	//------------------------------------------------------------
	//		ledger line
	//------------------------------------------------------------
	fileprivate func checkNoteLine() {

		//	Check ledger line
		if ( currentViewNum%2 == 1 ){
			//	F-clef
			let nt_E1:HSBSmNote? = ntArray[MIN_NOTE_NUMBER]
			if nt_E1 != nil {	//	E1
				ntlineState[LEDGER_LINE_BELOW] = LINE_NORM
			}
			else {
				ntlineState[LEDGER_LINE_BELOW] = LINE_NOTHING
			}
		}

		else {
			//	G-clef
			let nt_C3:HSBSmNote? = ntArray[CENTER_NOTE_NUMBER]
			if nt_C3 != nil {	//	C3
				ntlineState[LEDGER_LINE_BELOW] = LINE_NORM;
			}
			else {
				ntlineState[LEDGER_LINE_BELOW] = LINE_NOTHING;
			}
	
			let nt_A4:HSBSmNote? = ntArray[MAX_NOTE_NUMBER-1]
			let nt_B4:HSBSmNote? = ntArray[MAX_NOTE_NUMBER]
			if nt_A4 != nil && nt_B4 != nil {	//	A4 & B4
				if (( nt_A4!.rightOfs == 1 ) || ( nt_B4!.rightOfs == 1 )){
					ntlineState[LEDGER_LINE_ABOVE] = LINE_LONG
				}
			}
			else if nt_A4 == nil && nt_B4 != nil {
				if ( nt_B4!.rightOfs == 1 ){ ntlineState[LEDGER_LINE_ABOVE] = LINE_RIGHT }
				else { ntlineState[LEDGER_LINE_ABOVE] = LINE_NORM }
			}
			else if nt_A4 != nil && nt_B4 == nil {
				if ( nt_A4!.rightOfs == 1 ){ ntlineState[LEDGER_LINE_ABOVE] = LINE_RIGHT }
				else { ntlineState[LEDGER_LINE_ABOVE] = LINE_NORM }
			}
			else {
				ntlineState[LEDGER_LINE_ABOVE] = LINE_NOTHING
			}
		}
	
		//	Call drawRect
		let x:CGFloat = CGFloat(currentViewNum/2)*VIEW_WIDTH
		let y:CGFloat = CGFloat(currentViewNum%2)*VIEW_HEIGHT
		setNeedsDisplay( CGRect(x: x, y: y, width: VIEW_WIDTH, height: VIEW_HEIGHT) )
	}
	//------------------------------------------------------------
	//	Calculate right offset position by accidental Mark
	//------------------------------------------------------------
	//
	//	考え方
	//	音符の左側にある臨時記号が縦に何列になるかという数値をオフセット数と呼ぶ
	//	複数の音符のかたまりの音程が、４つ完全に連続している時、臨時記号の最大オフセット数4となる
	//	４度内に３音ある場合オフセット数3、２音ならオフセット数2、1音しかなければオフセットは1
	//	nt.acciRightOfs も音符に近いほど数値は小さい
	//
	//------------------------------------------------------------
	let CANCEL_VALUE = 100
	//------------------------------------------------------------
	fileprivate func calcAcciRightOfs() -> Bool {
		var ret = false
		var noteStkIn4thInt = [HSBSmNote]()
		var lowestAcciNt:Int = CANCEL_VALUE
		var lastAcciNt:Int = 0
		var lowestAcciPosition:Int = 0
		var countDownFlg = false
		
		for i in 0 ..< (MAX_NOTE_NUMBER+1) {
			if let nt = ntArray[i] {
				// over 4 interval from 1st note
				if lastAcciNt+4 <= i {
					noteStkIn4thInt = [HSBSmNote]()
					lowestAcciPosition = 0
					lowestAcciNt = CANCEL_VALUE
					countDownFlg = false
				}
				else if lowestAcciNt+4 <= i {
					noteStkIn4thInt = [HSBSmNote]()
					lowestAcciPosition = ntArray[lowestAcciNt]!.acciRightOfs
					lowestAcciNt = CANCEL_VALUE
					countDownFlg = true
				}
				
				if nt.acciState != 0 {
					nt.acciRightOfs = lowestAcciPosition
					if countDownFlg == true {
						if lowestAcciPosition == 0 { countDownFlg = false }
						else { lowestAcciPosition -= 1 }
					}
					else {
						for lowNt in noteStkIn4thInt {
							lowNt.acciRightOfs += 1
						}
					}
					noteStkIn4thInt.append(nt)
					if lowestAcciNt == CANCEL_VALUE {
						lowestAcciNt = i
					}
					lastAcciNt = i
					ret = true
				}
			}
		}		
		return ret
	}
}

