//
//  RecordSoundViewController.swift
//  Pitch Perfect
//
//  Created by Marcel Oliveira Alves on 3/12/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - This class records audio when the microphone button is tapped
//  - It is possible to pause during the recording and start recording again
//  -- tapping pause button (pauseStopButton with "pause" image) pauses the audio
//  -- tapping mic button when the audio is paused will restart the recording (from where it was paused)
//  - To finish recording, the user must tap the stop button (pauseStopButton with "stop" image)
//  - After the recording is finished, a segue to PlaySoundsView is performed
//  - The recorded audio is passed (as RecordedAudio) to PlaySoundsViewController
//
//  "stop" and "pause" icons are protected by Creative Commons Copyright 3.0
//  The author is Robin Kylander (website: http://www.flaticon.com/authors/robin-kylander)
//
//  Original stop button image wasn't used to avoid being too different from the pause button image

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var pauseStopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        pauseStopButton.hidden = true
        recordButton.enabled = true
        recordingLabel.text = "Tap to record"
    }
    
    // Blinks recordingLabel according to timer
    func blinkRecordingLabel() {
        if (recordingLabel.alpha == 0.0) {
            UIView.animateWithDuration(Constants.FadeTimes.recordingLabel, animations: {self.recordingLabel.alpha = 1.0})
        } else {
            UIView.animateWithDuration(Constants.FadeTimes.recordingLabel, animations: {self.recordingLabel.alpha = 0.0})
        }
    }
    
    // Records audio
    // if audioRecorder == nil, records new audio
    // otherwise resumes the recording (that is paused)
    func recordAudio() {
        if (audioRecorder == nil) {
            print("Recording new audio")
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            
            // Creating a unique name based on date and time and using it to create a filePath
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            print(filePath)
            
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch _ {
            }
            
			audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: [String : AnyObject]())
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else {
            print("Resuming recording audio")
            audioRecorder.record()
        }
    }
    
    // Perform many UI configurations when micButton is tapped and also calls recordAudio
    @IBAction func micButtonTapped(sender: UIButton) {
        recordingLabel.alpha = 1.0
        recordingLabel.text = "recording"
        pauseStopButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        pauseStopButton.hidden = false
        recordButton.enabled = false
        
        // start timer to make recordingLabel blink - indicates that the app is working
        timer = NSTimer.scheduledTimerWithTimeInterval(Constants.FadeTimes.recordingLabel, target:self, selector: Selector("blinkRecordingLabel"), userInfo: nil, repeats: true)
        
        recordAudio()
    }
    
    // Treat events when pauseStopButton is tapped
    // If audioRecorder is recording ("pause" image in the button), it stops the recording and changes
    // the button image ("stop" image). If it isn't recording, audioRecorder stops and the delegate method
    // audioRecorderDidFinishRecording will be called (segue will be performed)
    @IBAction func pauseStopButtonTapped(sender: UIButton) {
        if (audioRecorder.recording) {
            print("Recording paused")
            
            // stop timer; recordingLabel stops blinking
            timer.invalidate()
            
            recordingLabel.alpha = 1.0
            recordingLabel.text = "recording paused"
            audioRecorder.pause()
            recordButton.enabled = true
            pauseStopButton.setImage(UIImage(named: "stop"), forState: UIControlState.Normal)
        } else {
            print("Recording is finished! Delegate will perform segue")
            audioRecorder.stop()
            
            // guarantees that a new audio will be recorded when the user go back to RecordSoundView
            // the test is performed in recordAudio
            audioRecorder = nil
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch _ {
            }
        }
    }
    
    // Perform segue to PlaySoundsView if the audio was successfully recorded
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("recordPlaySegue", sender: recordedAudio)
        } else {
            print("Recording not successful")
            recordButton.enabled = true
            pauseStopButton.hidden = true
        }
    }
    
    // Passes audioData (RecordedAudio) to PlaySoundViewController when the segue is performed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "recordPlaySegue") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}

