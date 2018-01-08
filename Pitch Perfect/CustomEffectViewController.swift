//
//  CustomEffectViewController.swift
//  UdacityPitchPerfect
//

import UIKit
import AVFoundation

class CustomEffectViewController: UIViewController {
    
    @IBOutlet weak var distPregainSlider: UISlider!
    @IBOutlet weak var distMixSlider: UISlider!
    @IBOutlet weak var pitchOverlapSlider: UISlider!
    @IBOutlet weak var pitchPitchSlider: UISlider!
    @IBOutlet weak var pitchRateSlider: UISlider!

    // MARK: Class variables
    
    var receivedAudio: RecordedAudio!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
    }
}
