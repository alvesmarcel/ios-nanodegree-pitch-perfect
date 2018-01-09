//
//  PlaySoundViewController.swift
//  UdacityPitchPerfect
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
	
	fileprivate struct AudioParam {
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
    fileprivate var audioPlayer:AVAudioPlayer!
	
	// Used to pitch and delay effects
    fileprivate var audioEngine:AVAudioEngine!
    fileprivate var audioFile:AVAudioFile!
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

        audioPlayer = try? AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
        audioPlayer.enableRate = true // required to change the audio rate
		
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Stops audio and deletes the file from the system
		stopAudio()
		do {
			try FileManager.default.removeItem(at: receivedAudio.filePathUrl as URL)
		} catch let error as NSError {
			print("File could not be removed. \(error.localizedDescription)")
		}
	}
	
	// MARK: IBActions
	
	// Selects the correct function to call for the specific button tapped
	@IBAction func playSoundForButton(_ sender: UIButton) {
		
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
	@IBAction func stopButtonTapped(_ sender: UIButton) {
		stopAudio()
	}
    
    @IBAction func customButtonTapped(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "CustomEffectViewController") as! CustomEffectViewController
        controller.receivedAudio = receivedAudio
        self.show(controller, sender: self)
    }
	
	// MARK: Play and stop audio methods
	
	// Plays audio player with the specified rate
	func playAudioPlayerWithRate(_ rate: Float) {
		audioPlayer.rate = rate
		audioPlayer.play()
	}
	
	// Plays audio with an audio engine, applying an audio effect
	func playAudioEngineWithEffect(_ audioUnitEffect: AVAudioUnit) {
		
		// Initialize audioEngine
		let audioPlayerNode = AVAudioPlayerNode()
		audioEngine.attach(audioPlayerNode)

		// Attaches the effect to the audio engine and connects it to the output
		audioEngine.attach(audioUnitEffect)
		audioEngine.connect(audioPlayerNode, to: audioUnitEffect, format: nil)
		audioEngine.connect(audioUnitEffect, to: audioEngine.outputNode, format: nil)
		
		// Schedules the file to play and starts the audio engine
		audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
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
	func getPitchEffect(_ pitch: Float) -> AVAudioUnit {
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        return changePitchEffect
    }
    
    // Returns the delay effect with a delay time
    func getReverbEffect(_ wetDryMix: Float) -> AVAudioUnit {
        let reverbEffect = AVAudioUnitReverb()
		reverbEffect.loadFactoryPreset(.cathedral)
        reverbEffect.wetDryMix = wetDryMix
		return reverbEffect
    }
}
