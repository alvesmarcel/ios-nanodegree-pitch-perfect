//
//  PlaySoundViewController.swift
//  UdacityPitchPerfect
//
//  Created by Marcel Oliveira Alves on 3/18/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - Plays the recorded audio with an effect (Slow, Fast, Chipmunk, Darth Vader or Delay)
//

import UIKit
import AVFoundation

class PlaySoundViewController: UIViewController {
	
	// MARK: Outlets
	
	@IBOutlet weak var slowEffectButton: UIButton!
	@IBOutlet weak var fastEffectButton: UIButton!
	@IBOutlet weak var chipmunkEffectButton: UIButton!
	@IBOutlet weak var darthVaderEffectButton: UIButton!
	@IBOutlet weak var reverbEffectButton: UIButton!
	
	// MARK: Constants
	
	private struct AudioParam {
		// Audio rate, range: 0.5 (half speed) - 2.0 (double speed)
		static let Slow = Float(0.5)
		static let Fast = Float(1.5)
		
		// Pitch modifier, range: -2400 (2 octaves down) - 2400 (2 octaves up)
		static let Chipmunk = Float(1000)
		static let DarthVader = Float(-1000)
		
		// Reverb wet/dry mix, range: 0 (no mix) - 100 (total mix)
		static let Reverb = Float(70.0)
	}
	
	// MARK: Class variables
	
	// The filePathUrl is used by both: audioPlayer and audioEngine
	var receivedAudio: RecordedAudio!
	
	// Used to change audio rate
    var audioPlayer:AVAudioPlayer!
	
	// Used to pitch and delay effects
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true // required to change the audio rate
		
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Stops audio and deletes the file from the system
		stopAudio()
		do {
			try NSFileManager.defaultManager().removeItemAtURL(receivedAudio.filePathUrl)
		} catch let error as NSError {
			print("File could not be removed. \(error.localizedDescription)")
		}
	}
	
	// MARK: IBActions
	
	// Selects the correct function to call for the specific button tapped
	@IBAction func playSoundForButton(sender: UIButton) {
		
		// Stop audio that might be playing to avoid unexpected behavior
		stopAudio()
		
		// Selecting the correct effect to apply
		switch (sender) {
		case slowEffectButton:
			playAudioPlayerWithRate(AudioParam.Slow)
			break
		case fastEffectButton:
			playAudioPlayerWithRate(AudioParam.Fast)
			break
		case chipmunkEffectButton:
			playAudioEngineWithEffect(getPitchEffect(AudioParam.Chipmunk))
			break
		case darthVaderEffectButton:
			playAudioEngineWithEffect(getPitchEffect(AudioParam.DarthVader))
			break
		case reverbEffectButton:
			playAudioEngineWithEffect(getReverbEffect(AudioParam.Reverb))
			break
		default:
			print("Unexpected button tapped")
		}
	}
	
	// Stops audioPlayer (for slow and fast effects) and audioEngine (for pitch and delay effects)
	@IBAction func stopButtonTapped(sender: UIButton) {
		stopAudio()
	}
	
	// MARK: Play and stop audio methods
	
	// Plays audio player with the specified rate
	func playAudioPlayerWithRate(rate: Float) {
		audioPlayer.rate = rate
		audioPlayer.play()
	}
	
	// Plays audio with an audio engine, applying an audio effect
	func playAudioEngineWithEffect(audioUnitEffect: AVAudioUnit) {
		
		// Initialize audioEngine
		let audioPlayerNode = AVAudioPlayerNode()
		audioEngine.attachNode(audioPlayerNode)

		// Attaches the effect to the audio engine and connects it to the output
		audioEngine.attachNode(audioUnitEffect)
		audioEngine.connect(audioPlayerNode, to: audioUnitEffect, format: nil)
		audioEngine.connect(audioUnitEffect, to: audioEngine.outputNode, format: nil)
		
		// Schedules the file to play and starts the audio engine
		audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
		do {
			try audioEngine.start()
		} catch let error as NSError {
			print("Error starting audio engine. \(error.localizedDescription)")
		}
		
		// Plays audio player
		audioPlayerNode.play()
	}
	
	// Stops both audioPlayer and audioEngine
	func stopAudio() {
		audioPlayer.stop()
		audioPlayer.currentTime = 0.0
		audioEngine.stop()
		audioEngine.reset()
	}
	
	// MARK: Helper methods
	
    // Returns a pitch effect (used for Darth Vader or Chipmunk effects)
	func getPitchEffect(pitch: Float) -> AVAudioUnit {
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        return changePitchEffect
    }
    
    // Returns the delay effect with a delay time
    func getReverbEffect(wetDryMix: Float) -> AVAudioUnit {
        let reverbEffect = AVAudioUnitReverb()
		reverbEffect.loadFactoryPreset(.Cathedral)
        reverbEffect.wetDryMix = wetDryMix
		return reverbEffect
    }
}