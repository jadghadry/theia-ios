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
            synthesizer.stopSpeaking(at: .immediate)
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
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
    
    /**
     Configures the SFSpeechRecognizer object using an english locale.
     */
    
    internal func configureLottieAnimation() {
        self.lottieVoiceAnimation.loopAnimation = true
    }
    
    
    
    /**
     Sets the category, mode, and desired options on the shared AVAudioSession, then activates it for audio multi-routing.
     */
    
    internal func setUpAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("An error has occurred while setting the AVAudioSession.")
        }
        
    }
    
    
    
    /**
     Initializes the SFSpeechRecognizer object using an english locale.
     */
    
    internal func setUpSpeechRecognizer() {
        
        let englishLocale = Locale(identifier: "en-US")
        
        self.speechRecognizer = SFSpeechRecognizer(locale: englishLocale)
        self.speechRecognizer?.delegate = self
        
    }
    
    
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        // Call relevant view controller configurations.
        self.setUpSpeechRecognizer()
        self.setUpAudioSession()
        self.configureLottieAnimation()
        
        // Request speech input authorization.
        self.requestSpeechRecognitionAuthorization()
        
    }
    
}
