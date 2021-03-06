//
//  MainViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 9/29/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import BLTNBoard
import Lottie
import Speech

class MainViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lottieVoiceAnimation: LOTAnimationView!
    
    
    
    // MARK: - Constant Properties
    
    let audioEngine = AVAudioEngine()
    
    
    
    // MARK: - Lazy Properties
    
    lazy var bulletinManager: BLTNItemManager = {
        let rootItem = self.onboardingIntroduction()
        return BLTNItemManager(rootItem: rootItem)
    }()
    
    
    
    // MARK: - Optional Properties
    
    var command: String?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var speechRecognizer: SFSpeechRecognizer?
    
    
    
    // MARK: - Actions
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        
        // Check wether the synthesizer is speaking.
        THSpeechSynthesizer.shared.toggleSpeaking({ [weak self] isSpeaking in
            
            if isSpeaking {
                return
            }
            
            // Check the audio engine status.
            if let audioEngine = self?.audioEngine, audioEngine.isRunning {
                
                // If the audio engine was running, then we need to stop receiving audio input.
                self?.stopSpeechRecognition()
                self?.runCommand()
                
            } else {
                
                // If the audio engine was not running, then we need to start receiving audio input.
                self?.startSpeechRecognition()
                
            }
            
        })
        
    }
    
    
    
    // MARK: - Functions
    
    /**
     Configures the main lottie animation.
     */
    
    internal func configureLottieAnimation() {
        self.lottieVoiceAnimation.loopAnimation = true
    }
    
    
    
    /**
     Adds an observer to the default Notification Center in order to handle audio routing modifications.
     */
 
    internal func setUpNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    
    
    /**
     Sets the category, mode, and desired options on the shared AVAudioSession, then activates it for audio multi-routing.
     */
    
    internal func setUpAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ An error has occurred while configuring the AVAudioSession.")
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
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        self.showOnboardingScreens()
        self.setUpSpeechRecognizer()
        self.setUpAudioSession()
        self.setUpNotifications()
        self.configureLottieAnimation()
        
    }
    
    
    
    /**
     Display onboarding screens to the user.
     Note that these screens should not be displayed if the user has already completed the onboarding procedure.
     */
    
    internal func showOnboardingScreens() {
        
        if !THUtilities.didFinishOnboarding() {
            
            DispatchQueue.main.async {
                self.bulletinManager.showBulletin(above: self)
            }
            
        }
        
    }
    
}
