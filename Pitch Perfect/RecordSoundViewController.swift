//
//  RecordSoundViewController.swift
//  UdacityPitchPerfect
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

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {
	
	// MARK: Outlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var pauseStopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
	
	// MARK: Constants
	
	private let kRecordingLabelFadeTime = 0.5
	enum UIState { case Stopped, Paused, Recording }
	
	// MARK: Class variables
	
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var timer = NSTimer()
	
	// MARK: Lifecycle
	
    override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// audioRecorder should be set to nil to record new audio
		audioRecorder = nil
		
		// The initial state when the view appears should be Stopped
		configureUI(UIState.Stopped)
    }
	
	// MARK: IBActions
	
	// Changes UI state to Recording and calls recordAudio to save audio in a file
	@IBAction func micButtonTapped(sender: UIButton) {
		configureUI(UIState.Recording)
		recordAudio()
	}

	// Configures the UI and stop or pause recording depending on whether the audioRecorder is recording
	@IBAction func pauseStopButtonTapped(sender: UIButton) {
		
		// audioRecorder recording: tapping the button should pause the recording
		if (audioRecorder.recording) {
			configureUI(UIState.Paused)
			audioRecorder.pause()
		}
		
		// audioRecorder not recording: recording is paused; tapping the button should stop the recording
		else {
			audioRecorder.stop()
			
			// Sets AVAudioSession shared instance to be inactive
			// This will activate audioRecorderDidFinishRecording:succesfully:
			do {
				try AVAudioSession.sharedInstance().setActive(false)
			} catch let error as NSError {
				print("AVAudioSession sharedInstance could not be set inactive. \(error.localizedDescription)")
			}
		}
	}
	
	// MARK: Record audio
    
    // Records audio: if audioRecorder == nil, records new audio; otherwise, resume paused recording
    func recordAudio() {
		
		// Records new audio
        if (audioRecorder == nil) {
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
            } catch let error as NSError {
				print("Error trying to set audio session category. \(error.localizedDescription)")
            }
			
			// Initialize audioRecorder and sets its delegate
			audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: [String : AnyObject]())
            audioRecorder.delegate = self
			
			// Start recording
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
		
		// Recording is paused: resume the recording
		else {
            audioRecorder.record()
        }
    }
	
	// MARK: AVAudioRecorderDelegate methods
	
    // Perform segue to PlaySoundsViewController if the audio was successfully recorded
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		if (flag) {
			// Recording was successful: perform segue
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
			
			// Presenting PlaySoundsViewController and passing the recordedAudio to it
			let controller = storyboard?.instantiateViewControllerWithIdentifier("PlaySoundViewController") as! PlaySoundViewController
			controller.receivedAudio = recordedAudio
			self.showViewController(controller, sender: self)
        } else {
			// Recording was not successful: should go back to initial state
            print("Recording not successful")
            configureUI(UIState.Stopped)
        }
    }
	
	// MARK: Helper methods
	
	// Configure UI based on the UIState informed
	func configureUI(state: UIState) {
		switch (state) {
		case .Stopped:
			pauseStopButton.hidden = true
			recordButton.enabled = true
			recordingLabel.text = "Tap to record"
			break
		case .Paused:
			timer.invalidate()
			recordingLabel.alpha = 1.0
			recordingLabel.text = "recording paused"
			recordButton.enabled = true
			pauseStopButton.setImage(UIImage(named: "stop2x-iphone"), forState: UIControlState.Normal)
			break
		case .Recording:
			recordingLabel.alpha = 1.0
			recordingLabel.text = "recording"
			pauseStopButton.setImage(UIImage(named: "pause_200_blue"), forState: UIControlState.Normal)
			pauseStopButton.hidden = false
			recordButton.enabled = false
			timer = NSTimer.scheduledTimerWithTimeInterval(kRecordingLabelFadeTime, target:self, selector: "blinkRecordingLabel", userInfo: nil, repeats: true)
			break
		}
	}
	
	// Blinks recordingLabel according to timer
	func blinkRecordingLabel() {
		if (recordingLabel.alpha == 0.0) {
			UIView.animateWithDuration(kRecordingLabelFadeTime, animations: {self.recordingLabel.alpha = 1.0})
		} else {
			UIView.animateWithDuration(kRecordingLabelFadeTime, animations: {self.recordingLabel.alpha = 0.0})
		}
	}
}