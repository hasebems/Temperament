//
//  ToneGenerator.swift
//  Temperament
//
//  Created by 長谷部 雅彦 on 2015/06/27.
//  Copyright (c) 2015年 長谷部 雅彦. All rights reserved.
//

import Foundation

//----------------------------------------------------------------
//				Define public const number
//----------------------------------------------------------------
let	NO_MIDI_NOTE:UInt8	=	0xff
let POSITION_MAX		=	26
let TUNING_SEND_INDEX_MAX = 48

//----------------------------------------------------------------
//				Define TemperamentToneGenerator Class
//----------------------------------------------------------------
class TemperamentToneGenerator : NSObject {

	let ssEngine = AudioOutput()
	
	//------------------------------------------------------------
	//				Define const numbers
	//------------------------------------------------------------
	//	for Handle
	//	0 ... 34 : C1 of "bb,b,nat,#,##" (5vari) to B1 (5*7=35)
	//	35 ... 69 : C2 - B2
	//	70 ... 104 : C3 - B3
	//	105 ... 139 : C4 - B4
	let HANDLE_OCTAVE		=	35
	let HANDLE_NOTE_IN_OCT	=	7
	let HANDLE_VARI			=	5
	let NOTE_IN_OCT			=	7
	
	//------------------------------------------------------------
	//				Variables
	//------------------------------------------------------------
	struct NoteStatus {
		var	midiNote: UInt8 = NO_MIDI_NOTE
		var velVari: UInt8 = 0		//	0-3
		var doremi: Int = 0
		var oct: Int = 0
		var handle: Int = 0
	}
	//------------------------------------------------------------
	var customCents = [Double]( count:12, repeatedValue:0 )
	var totalTuning: Double = 440
	//------------------------------------------------------------
	//	same as crntKey of ViewController
	private var musicalKey: Int = 0				//	-7 - 0 - 7
	private var temperamentType: Int = 0		//	0 - tTemperament.count
	private var noteStatus: [NoteStatus] = []	//	Index: Position
	private var temperamentTuningData = [Double]( count:TUNING_SEND_INDEX_MAX, repeatedValue:0 )
												//	refer to "double _tmperamentPitch[4][12]" of tmporg_instrument.h
	private var justIntoCents = [Double]( count:21, repeatedValue:0 )	//	[3][7]

	//------------------------------------------------------------
	//				Tables
	//------------------------------------------------------------
	let tNoteName = [ "C","D","E","F","G","A","B" ]
	let tAcciVari = [ "bb", "b", "", "#", "##" ]
	let tToneType: [Int] = [
		//	0: The note should change to Dobble Flat, Flat, Natural
		//	1: The note should change to  Flat, Natural, Sharp
		//	2: The note should change to  Natural, Sharp, Double Sharp
		0,0,0,0,0,0,0,
		0,0,0,1,0,0,0,
		1,0,0,1,0,0,0,
		1,0,0,1,1,0,0,
		1,1,0,1,1,0,0,
		1,1,0,1,1,1,0,
		1,1,1,1,1,1,0,
		1,1,1,1,1,1,1,	//	C,D,E,F,G,A,B
		1,1,1,2,1,1,1,
		2,1,1,2,1,1,1,
		2,1,1,2,2,1,1,
		2,2,1,2,2,1,1,
		2,2,1,2,2,2,1,
		2,2,2,2,2,2,1,
		2,2,2,2,2,2,2
	]
	let tHandleToPitchIndex: [Int] = [
		//	Index for temperamentTuningData[]
		46,35,0,1,14,	//	Cbb,Cb,C,C#,C##
		36,25,2,3,16,
		38,27,4,17,18,
		39,28,5,6,19,
		41,30,7,8,21,
		43,32,9,10,23,
		45,34,11,12,13
	]
	//------------------------------------------------------------
	//				Initializer
	//------------------------------------------------------------
	override init() {
		super.init()

		//	Initialize
		for _ in 0 ..< POSITION_MAX {
			noteStatus.append( NoteStatus() )
		}

		//	Make JustIntonation
		let ratio: Double = Double(3)/2
		let mj3ratio: Double = Double(5)/4
		
		//	f-d-s-r
		justIntoCents[7+3]  = 1200*log(pow(ratio,-1))/log(2) + 1200 - 500
		justIntoCents[7+0]  = 1200*log(pow(ratio,0))/log(2)
		justIntoCents[7+4]  = 1200*log(pow(ratio,1))/log(2) - 700
		justIntoCents[7+1]  = 1200*log(pow(ratio,2))/log(2) - 1200 - 200
		
		//	a-m-t-fi
		justIntoCents[7+5]  = 1200*log(pow(ratio,-1)*pow(mj3ratio,1))/log(2) + 1200 - 900
		justIntoCents[7+2]  = 1200*log(pow(ratio,0)*pow(mj3ratio,1))/log(2) - 400
		justIntoCents[7+6]  = 1200*log(pow(ratio,1)*pow(mj3ratio,1))/log(2) - 1100
		justIntoCents[14+3]  = 1200*log(pow(ratio,2)*pow(mj3ratio,1))/log(2) - 1200 - 600
		
		//	di-si-ri-li
		justIntoCents[14+0]  = 1200*log(pow(ratio,-1)*pow(mj3ratio,2))/log(2) - 100
		justIntoCents[14+4]  = 1200*log(pow(ratio,0)*pow(mj3ratio,2))/log(2) - 800
		justIntoCents[14+1]  = 1200*log(pow(ratio,1)*pow(mj3ratio,2))/log(2) - 1200 - 300
		justIntoCents[14+5]  = 1200*log(pow(ratio,2)*pow(mj3ratio,2))/log(2) - 1200 - 1000
		
		//	mi#-ti#
		justIntoCents[14+2]  = 1200*log(pow(ratio,-1)*pow(mj3ratio,3))/log(2) - 500
		justIntoCents[14+6]  = 1200*log(pow(ratio,0)*pow(mj3ratio,3))/log(2) - 1200
		
		//	ra-lo-ma-ta
		justIntoCents[0+1]  = 1200*log(pow(ratio,-1)*pow(mj3ratio,-1))/log(2) + 1200 - 100
		justIntoCents[0+5]  = 1200*log(pow(ratio,0)*pow(mj3ratio,-1))/log(2) + 1200 - 800
		justIntoCents[0+2]  = 1200*log(pow(ratio,1)*pow(mj3ratio,-1))/log(2) - 300
		justIntoCents[0+6]  = 1200*log(pow(ratio,2)*pow(mj3ratio,-1))/log(2) - 1000
		
		//	fab-da-sa
		justIntoCents[0+3]  = 1200*log(pow(ratio,0)*pow(mj3ratio,-2))/log(2) + 1200 - 400
		justIntoCents[0+0]  = 1200*log(pow(ratio,1)*pow(mj3ratio,-2))/log(2) + 1200 - 1100
		justIntoCents[0+4]  = 1200*log(pow(ratio,2)*pow(mj3ratio,-2))/log(2) - 600
	
	}
	//------------------------------------------------------------
	//				IF Function
	//------------------------------------------------------------
	func keyOn( pos: Int, acc: Int ) -> Int {
		//	pos : 0:E1, 12:C3, 25:B4
		//	acc : -1:down, 0:natural, 1:up

		//	make MIDI note/vel and Send Message
		let ns = makeMidiNote(pos, acc:acc)
		noteStatus[pos] = ns
		let note = ns.midiNote
		let vel = 0x7f - ns.velVari
		ssEngine.receiveMidi( 0x90, msg2: note, msg3: vel )

		//	return handle
		return ns.handle
	}
	//------------------------------------------------------------
	func keyOff( pos: Int ) {
		let note = noteStatus[pos].midiNote
		let vel = 0x43 - noteStatus[pos].velVari
		if note != NO_MIDI_NOTE {
			ssEngine.receiveMidi( 0x80, msg2: note, msg3: vel )
		}
	}
	//------------------------------------------------------------
	func allOff(){
		ssEngine.receiveMidi(0xb0, msg2:120, msg3: 0)
	}
	//------------------------------------------------------------
	func changeKey( key: Int ){
		musicalKey = key
		if temperamentType == 3 {
			generateJustIntonation()
		}
	}
	//------------------------------------------------------------
	func changeTune( tune: Double ){
		//	tune shoule be 376 - 503[Hz]
		var ttune = tune
		if tune < 376 { ttune = 376 }
		else if tune > 503 { ttune = 503 }
		totalTuning = ttune
		ssEngine.receiveMidi(0xb0, msg2:13, msg3: UInt8(ttune-376) )
	}
	//------------------------------------------------------------
	func changeTemparament( tmpl: Int ){
		temperamentType = tmpl
		switch (tmpl){
		case 0: 		generateEqualTemparament()
		case 1,2: 		generatePythagorean(tmpl-1)
		case 3:			generateJustIntonation()
		case 4,5,6,7:	generateMeantone(tmpl-4)
		case 8:			generateWerkmeister()
		case 9,10,11:	generateKirnberger(tmpl-9)
		case 12:		generateCustom()
		default:		generateEqualTemparament()
		}
	}
	//------------------------------------------------------------
	func getNoteText( handle: Int ) -> String {

		if ( handle < 0 ) || ( handle > HANDLE_OCTAVE*4 ) {
			return "---"
		}
		
		let oct: Int = (handle/HANDLE_OCTAVE) + 1
		let numInOct = handle%HANDLE_OCTAVE
		let note: Int = numInOct/HANDLE_VARI
		let acci = numInOct%HANDLE_VARI
		return tNoteName[note] + tAcciVari[acci] + String(oct)
	}
	//------------------------------------------------------------
	func getHz( handle: Int ) -> Double {
		let oct:Int = (handle+10)/HANDLE_OCTAVE
		let hdl = handle%HANDLE_OCTAVE
		let pidx = tHandleToPitchIndex[hdl]
		var nt = pidx%12 + 3
		var cent = temperamentTuningData[pidx]
		while (nt>=12){ nt-=12 }
		cent += Double(nt)*100
		return exp((cent/1200)*log(2))*pow(2,Double(oct))*totalTuning/8
	}
	//------------------------------------------------------------
	func getCent( handle: Int, cmd: Int ) -> Double {
		let hdl = handle%HANDLE_OCTAVE
		let pidx = tHandleToPitchIndex[hdl]
		var nt = pidx%12
		var cent = temperamentTuningData[pidx]
		if cmd == 0 {
			nt += musicalKey*5	//	one '#' means 5th upper
			while (nt<0){ nt+=12 }
			while (nt>=12){ nt-=12 }
			cent += Double(nt)*100
		}
		else {
			nt += 3
			while (nt>=12){ nt-=12 }
			cent += (Double(nt)*100 - temperamentTuningData[9])	//	make A 0
		}
		return cent
	}
	
	//------------------------------------------------------------
	//			Private Functions
	//------------------------------------------------------------
	let tDoremi2Midi:[Int] = [0,2,4,5,7,9,11]
	//------------------------------------------------------------
	private func makeMidiNote( pos: Int, acc: Int ) -> NoteStatus {
		//	Input
		//		pos : 0:E1, 12:C3, 25:B4
		//		acc : -1:down, 0:natural, 1:up
		//	Output
		//		NoteStatus.midiNote	: same as MIDI Note Number
		//		NoteStatus.velVari	: 0-3, value that should minus from velocity

		var ns = NoteStatus()

		//	make doremi,oct
		ns.doremi = (pos+2)%NOTE_IN_OCT
		ns.oct = (pos+2)/NOTE_IN_OCT
		let type = tToneType[(musicalKey+7)*NOTE_IN_OCT + ns.doremi]
		let accType:Int = (acc+1) + type

		//	make handle
		ns.handle = ns.oct*HANDLE_OCTAVE + ns.doremi*HANDLE_VARI + accType

		//	make MIDI
		var nt:Int = 36 + (ns.oct)*12 + tDoremi2Midi[ns.doremi]
		while ( nt > 127 ){	nt -= 12;}
		ns.midiNote = UInt8(nt)

		//	adjust midiNote, velVari
		switch (accType){
		case 0://bb
			ns.midiNote -= 2
			ns.velVari = 3
		case 1://b
			ns.midiNote -= 1
			ns.velVari = 2
		case 2: ns.velVari = 0	//	natural
		case 3://#
			ns.midiNote += 1
			if (ns.doremi == 2) || (ns.doremi == 6) { ns.velVari = 1 }
			else { ns.velVari = 0 }
		case 4://##
			ns.midiNote += 2
			ns.velVari = 1
		default: ns.velVari = 0
		}
		
		return ns
	}
	//------------------------------------------------------------
	private func sendAllTunings(){
		
		for cnt in 0 ..< TUNING_SEND_INDEX_MAX {
			var dt = temperamentTuningData[cnt]
			dt *= 100
			dt += 0.5
			var sendDt: Int = Int(dt)
			sendDt += 32768
			if sendDt >= 65536 { sendDt = 65535}
			else if sendDt <= 0 { sendDt = 0 }

			let prm1: UInt8 = UInt8(sendDt/256)
			let prm2: UInt8 = UInt8(sendDt & 0x00ff)
			
			if cnt == 0 {
				ssEngine.receiveMidi( 0xF1, msg2: prm1, msg3: prm2 )
			}
			else {
				ssEngine.receiveMidi( 0xF2, msg2: prm1, msg3: prm2 )
			}
		}
	}
	//------------------------------------------------------------
	//			Calculate Each Temperament
	//------------------------------------------------------------
	private func generateEqualTemparament(){
		//	all clear
		for cnt in 0 ..< TUNING_SEND_INDEX_MAX {
			temperamentTuningData[cnt] = 0
		}
		sendAllTunings()
	}
	//------------------------------------------------------------
	private func generatePythagorean( tmpr: Int ){
		for vv in 0 ..< 4 {

			var ratio: Double = Double(3)/2
			temperamentTuningData[vv*12+0]  = 0
			temperamentTuningData[vv*12+7]  = 1200*log(pow(ratio,1))/log(2) - 700
			temperamentTuningData[vv*12+2]  = 1200*log(pow(ratio,2))/log(2) - 1200 - 200
			
			if ( tmpr == 0 ){
				temperamentTuningData[vv*12+9]  = 1200*log(pow(ratio,3))/log(2) - 1200 - 900
				temperamentTuningData[vv*12+4]  = 1200*log(pow(ratio,4))/log(2) - 2400 - 400
				temperamentTuningData[vv*12+11] = 1200*log(pow(ratio,5))/log(2) - 2400 - 1100
				temperamentTuningData[vv*12+6]  = 1200*log(pow(ratio,6))/log(2) - 3600 - 600
				temperamentTuningData[vv*12+1]  = 1200*log(pow(ratio,7))/log(2) - 4800 - 100
				temperamentTuningData[vv*12+8]  = 1200*log(pow(ratio,8))/log(2) - 4800 - 800
			}

			ratio = Double(2)/3
			if ( tmpr == 1 ) {
				temperamentTuningData[vv*12+9]  = 1200*log(pow(ratio,9))/log(2) + 7200 - 900
				temperamentTuningData[vv*12+4]  = 1200*log(pow(ratio,8))/log(2) + 6000 - 400
				temperamentTuningData[vv*12+11] = 1200*log(pow(ratio,7))/log(2) + 6000 - 1100
				temperamentTuningData[vv*12+6]  = 1200*log(pow(ratio,6))/log(2) + 4800 - 600
				temperamentTuningData[vv*12+1]  = 1200*log(pow(ratio,5))/log(2) + 3600 - 100
				temperamentTuningData[vv*12+8]  = 1200*log(pow(ratio,4))/log(2) + 3600 - 800
			}
			temperamentTuningData[vv*12+3]  = 1200*log(pow(ratio,3))/log(2) + 2400 - 300
			temperamentTuningData[vv*12+10] = 1200*log(pow(ratio,2))/log(2) + 2400 - 1000
			temperamentTuningData[vv*12+5]  = 1200*log(pow(ratio,1))/log(2) + 1200 - 500
		}
		sendAllTunings()
	}
	//------------------------------------------------------------
	private func generateJustIntonation(){
		//	all clear
		for cnt in 0 ..< TUNING_SEND_INDEX_MAX {
			temperamentTuningData[cnt] = 0
		}

		for doremi in 0 ..< NOTE_IN_OCT {
			var nt = doremi + musicalKey*4
			while nt >= NOTE_IN_OCT { nt-=NOTE_IN_OCT }
			while nt < 0 { nt+=NOTE_IN_OCT }
			let type = tToneType[(musicalKey+7)*NOTE_IN_OCT + nt]
			let idx1 = tHandleToPitchIndex[nt*HANDLE_VARI+type]
			let idx2 = tHandleToPitchIndex[nt*HANDLE_VARI+type+1]
			let idx3 = tHandleToPitchIndex[nt*HANDLE_VARI+type+2]
			temperamentTuningData[idx1] = justIntoCents[doremi]
			temperamentTuningData[idx2] = justIntoCents[7+doremi]
			temperamentTuningData[idx3] = justIntoCents[14+doremi]
		}

		sendAllTunings()
	}
	//------------------------------------------------------------
	private func calcChromaticPitch( ratio:Double, cnt:Double ) -> Double {
		return (1200*log(pow(ratio,cnt)))/log(2)
	}
	//------------------------------------------------------------
	private func generateMeantone( tmpr:Int ){
		//	tmpr: 0-3 means 1/4,1/5,1/6,1/7
		
		for vv in 0 ..< 4 {
			var	ratio, comma: Double
			
			ratio = Double(3)/2
			comma = 1200*log(pow(ratio,4)/5)/(log(2)*Double(tmpr+4))
			
			temperamentTuningData[vv*12+0]  = 0
			temperamentTuningData[vv*12+7]  = calcChromaticPitch(ratio,cnt:1) - comma - 700
			temperamentTuningData[vv*12+2]  = calcChromaticPitch(ratio,cnt:2) - 1200 - comma*2 - 200
			temperamentTuningData[vv*12+9]  = calcChromaticPitch(ratio,cnt:3) - 1200 - comma*3 - 900
			temperamentTuningData[vv*12+4]  = calcChromaticPitch(ratio,cnt:4) - 2400 - comma*4 - 400
			temperamentTuningData[vv*12+11] = calcChromaticPitch(ratio,cnt:5) - 2400 - comma*5 - 1100
			temperamentTuningData[vv*12+6]  = calcChromaticPitch(ratio,cnt:6) - 3600 - comma*6 - 600
			temperamentTuningData[vv*12+1]  = calcChromaticPitch(ratio,cnt:7) - 4800 - comma*7 - 100
			temperamentTuningData[vv*12+8]  = calcChromaticPitch(ratio,cnt:8) - 4800 - comma*8 - 800
			
			ratio = Double(2)/3
			temperamentTuningData[vv*12+3]  = calcChromaticPitch(ratio,cnt:3) + 2400 + comma*3 - 300
			temperamentTuningData[vv*12+10] = calcChromaticPitch(ratio,cnt:2) + 2400 + comma*2 - 1000
			temperamentTuningData[vv*12+5]  = calcChromaticPitch(ratio,cnt:1) + 1200 + comma - 500
		}
		sendAllTunings()
	}
	//------------------------------------------------------------
	private func generateWerkmeister(){
		for vv in 0 ..< 4 {
			var	ratio, comma, perfct5thCent, tmpCent: Double
			
			ratio = Double(3)/2
			tmpCent = 1200*log(pow(ratio,8))/log(2)
			comma = (1200*7 - tmpCent)/4
			perfct5thCent = 1200*log(ratio)/log(2)
			
			temperamentTuningData[vv*12+0]  = 0
			temperamentTuningData[vv*12+7]  = comma - 700
			temperamentTuningData[vv*12+2]  = comma*2 - 1200 - 200
			temperamentTuningData[vv*12+9]  = comma*3 - 1200 - 900
			temperamentTuningData[vv*12+4]  = comma*3 + perfct5thCent - 2400 - 400
			temperamentTuningData[vv*12+11] = comma*3 + perfct5thCent*2 - 2400 - 1100
			temperamentTuningData[vv*12+6]  = comma*4 + perfct5thCent*2 - 3600 - 600
			
			temperamentTuningData[vv*12+1]  = 3600 - perfct5thCent*5 - 100
			temperamentTuningData[vv*12+8]  = 3600 - perfct5thCent*4 - 800
			temperamentTuningData[vv*12+3]  = 2400 - perfct5thCent*3 - 300
			temperamentTuningData[vv*12+10] = 2400 - perfct5thCent*2 - 1000
			temperamentTuningData[vv*12+5]  = 1200 - perfct5thCent*1 - 500
		}
		sendAllTunings()
	}
	//------------------------------------------------------------
	private func generateKirnberger( tmpl:Int ){
		for vv in 0 ..< 4 {
			var	ratio, comma, perfct5thCent, pure3rdCent: Double
			
			ratio = Double(3)/2
			comma = 1200*log(pow(ratio,4)/5)/log(2)
			perfct5thCent = 1200*log(ratio)/log(2)
			pure3rdCent = 1200*log(5)/log(2) - 2400

			temperamentTuningData[vv*12+0]  = 0
			temperamentTuningData[vv*12+4]  = pure3rdCent - 400
			if ( tmpl == 0 ){
				//	1st
				temperamentTuningData[vv*12+7]  = perfct5thCent - 700
				temperamentTuningData[vv*12+2]  = perfct5thCent*2 - 1200 - 200
				temperamentTuningData[vv*12+9]  = pure3rdCent - perfct5thCent + 1200 - 900
			}
			else if ( tmpl == 1 ){
				//	2nd
				temperamentTuningData[vv*12+7]  = perfct5thCent - 700
				temperamentTuningData[vv*12+2]  = perfct5thCent*2 - 1200 - 200
				temperamentTuningData[vv*12+9]  = pure3rdCent - perfct5thCent + 1200 + comma/2 - 900
			}
			else {
				//	3rd
				temperamentTuningData[vv*12+7]  = perfct5thCent - comma/4 - 700
				temperamentTuningData[vv*12+2]  = (perfct5thCent - comma/4)*2 - 1200 - 200
				temperamentTuningData[vv*12+9]  = (perfct5thCent - comma/4)*3 - 1200 - 900
			}
			
			temperamentTuningData[vv*12+11] = pure3rdCent + perfct5thCent - 1100
			temperamentTuningData[vv*12+6]  = pure3rdCent + perfct5thCent*2 - 1200 - 600
			
			temperamentTuningData[vv*12+1]  = 3600 - perfct5thCent*5 - 100
			temperamentTuningData[vv*12+8]  = 3600 - perfct5thCent*4 - 800
			temperamentTuningData[vv*12+3]  = 2400 - perfct5thCent*3 - 300
			temperamentTuningData[vv*12+10] = 2400 - perfct5thCent*2 - 1000
			temperamentTuningData[vv*12+5]  = 1200 - perfct5thCent*1 - 500
		}
		sendAllTunings()
	}
	//------------------------------------------------------------
	private func generateCustom(){
		for vv in 0 ..< 4 {
			for nn in 0 ..< 12 {
				temperamentTuningData[vv*12+nn] = customCents[nn]
			}
		}
		sendAllTunings()
	}

}
