//
//  MainViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 9/29/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import Speech
import Lottie

class MainViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lottieVoiceAnimation: LOTAnimationView!
    
    
    
    // MARK: - Constant Properties
    
    let audioEngine = AVAudioEngine()
    
    
    
    // MARK: - Optional Properties
    
    var command: String?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var speechRecognizer: SFSpeechRecognizer?
    
    
    
    // MARK: - Actions
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        
        let synthesizer = THSpeechSynthesizer.shared.synthesizer
        
        // Check wether the synthesizer is speaking.
        if synthesizer.isSpeaking {
            
            // Stop the speech.
            synthesizer.stopSpeaking(at: .immediate)
            
            // Provide a vibrating feedback.
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            
            // Exit the function scope.
            return
        }
        
        // Check the audio engine status.
        if self.audioEngine.isRunning {
            
            // If the audio engine was running, then we need to stop listenting for additional audio.
            self.stopSpeechRecognition()
            self.lottieVoiceAnimation.stop()
            self.runCommand(self.command)
            
        } else {
            
            // If the audio engine was not running, then we need to start listenting and recognizing audio.
            self.startSpeechRecognition()
            self.lottieVoiceAnimation.play()
            print("Listening")
            
        }
        
    }
    
    
    
    // MARK: - Functions
    
    internal func setUpLottieAnimations() {
        self.lottieVoiceAnimation.loopAnimation = true
    }
    
    
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        // Call relevant view controller configurations.
        self.setUpLottieAnimations()
        self.setUpSpeechRecognizer()
        
        // Request speech input authorization.
        self.requestSpeechRecognitionAuthorization()
        
    }
    
}
