//
//  RecordSoundViewController.swift
//  UdacityPitchPerfect
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {
	
    enum UIState { case stopped, recording }
    
	// MARK: Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseStopButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    let kRecordingLabelFadeTime = 1.0
    
	// MARK: Class variables

    private var audioRecorder:AVAudioRecorder!
    private var recordedAudio: RecordedAudio!
    private var timer = Timer()
	
	// MARK: Lifecycle
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// audioRecorder should be set to nil to record new audio
		audioRecorder = nil
		
		// The initial state when the view appears should be Stopped
		configureUI(UIState.stopped)
    }
	
	// MARK: IBActions
	
	// Changes UI state to Recording and calls recordAudio to save audio in a file
	@IBAction func micButtonTapped(_ sender: UIButton) {
		configureUI(UIState.recording)
		recordAudio()
	}

	// Configures the UI and stops or pauses recording depending on whether the audioRecorder is recording
	@IBAction func pauseStopButtonTapped(_ sender: UIButton) {
        audioRecorder.stop()
        
        // Sets AVAudioSession shared instance to be inactive
        // This will activate audioRecorderDidFinishRecording:succesfully:
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("AVAudioSession sharedInstance could not be set inactive. \(error.localizedDescription)")
        }
	}
	
	// MARK: Record audio
    
    // Records audio: if audioRecorder == nil, records new audio; otherwise, resume paused recording
    func recordAudio() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        // Creating a unique name based on date and time and using it to create a filePath
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.string(from: currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        print(filePath ?? "filePath is nil")
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("Error trying to set audio session category. \(error.localizedDescription)")
        }
        
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        // Initialize audioRecorder and sets its delegate
        audioRecorder = try? AVAudioRecorder(url: filePath!, settings: [String : AnyObject]())
        audioRecorder.delegate = self
        
        // Start recording
        audioRecorder.record()
    }
	
	// MARK: AVAudioRecorderDelegate methods
	
    // Perform segue to PlaySoundsViewController if the audio was successfully recorded
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if (flag) {
			// Recording was successful: perform segue
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
			
			// Presenting PlaySoundsViewController and passing the recordedAudio to it
			let controller = storyboard?.instantiateViewController(withIdentifier: "PlaySoundViewController") as! PlaySoundViewController
			controller.receivedAudio = recordedAudio
			self.show(controller, sender: self)
        } else {
			// Recording was not successful: should go back to initial state
            print("Recording not successful")
            configureUI(UIState.stopped)
        }
    }
	
	// MARK: Helper methods
	
	// Configure UI based on the UIState informed
	func configureUI(_ state: UIState) {
		switch (state) {
		case .stopped:
			pauseStopButton.isHidden = true
			recordButton.isEnabled = true
			recordingLabel.text = "Tap to record"
			break
		case .recording:
			recordingLabel.alpha = 1.0
			recordingLabel.text = "recording"
			pauseStopButton.setImage(UIImage(named: "stop2x-iphone"), for: UIControlState())
			pauseStopButton.isHidden = false
			recordButton.isEnabled = false
            timer = Timer.scheduledTimer(withTimeInterval: kRecordingLabelFadeTime, repeats: true, block: { timer in
                if (self.recordingLabel.alpha == 0.0) {
                    UIView.animate(withDuration: self.kRecordingLabelFadeTime, animations: {self.recordingLabel.alpha = 1.0})
                } else {
                    UIView.animate(withDuration: self.kRecordingLabelFadeTime, animations: {self.recordingLabel.alpha = 0.0})
                }
            })
			break
		}
	}
}
