//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Marcel Oliveira Alves on 3/18/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - Plays the recorded audio with an effect (slow, fast, chipmunk, Darth Vader, or delay)
//  -- The effect applied depends on the button tapped
//
//  "delay" and "stop" icons are protected by Creative Commons Copyright 3.0
//  The author is Robin Kylander (website: http://www.flaticon.com/authors/robin-kylander)
//
//  Original stop button image wasn't used to avoid being too different from the pause button image
//
//  Issue: The delay button is too small; this choice was made because it would be problematic to
//         fit all buttons in small screens (e.g. iPhone 4S)

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer:AVAudioPlayer! // Used to change audio rate
    var receivedAudio: RecordedAudio!
    
    var audioEngine:AVAudioEngine! // Used to pitch and delay effects
    var audioFile:AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true // required to change the audio rate
        
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
    
    // Plays audio with Darth Vader or Chipmunk effects (both are pitch changes)
    func playAudioWithVariablePitch(pitch: Float) {
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        audioPlayerNode.play()
    }
    
    // Plays the delay effect
    func playAudioWithDelay(delayTime: Float) {
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let delayEffect = AVAudioUnitDelay()
        delayEffect.delayTime = NSTimeInterval(delayTime)
        audioEngine.attachNode(delayEffect)
        
        audioEngine.connect(audioPlayerNode, to: delayEffect, format: nil)
        audioEngine.connect(delayEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        audioPlayerNode.play()
    }
    
    // Triggers when any effect button is tapped
    // Recognizes the button tapped through their tags (sender.tag)
    // Selects the correct function to call for the specific button tapped
    @IBAction func playAudio(sender: UIButton) {
        
        // Some setup to avoid unexpected behavior
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        audioEngine.stop()
        audioEngine.reset()

        // Selecting the correct effect to apply
        if (sender.tag == Constants.ButtonTags.slow) {
            audioPlayer.rate = Constants.AudioParams.slow
            audioPlayer.play()
        }
        else if (sender.tag == Constants.ButtonTags.fast) {
            audioPlayer.rate = Constants.AudioParams.fast
            audioPlayer.play()
        } else if (sender.tag == Constants.ButtonTags.chipmunk) {
            playAudioWithVariablePitch(Constants.AudioParams.chipmunk)
        } else if (sender.tag == Constants.ButtonTags.darthVader) {
            playAudioWithVariablePitch(Constants.AudioParams.darthVader)
        } else if (sender.tag == Constants.ButtonTags.delay) {
            playAudioWithDelay(Constants.AudioParams.delay)
        }
    }

    // Triggers when stopButton is tapped
    // Stops audioPlayer (for slow and fast effects) and audioEngine (for pitch and delay effects)
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
    }
}
