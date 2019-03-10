//
//  MainViewController+Onboarding.swift
//  theia-ios
//
//  Created by Jad Ghadry on 3/8/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import Foundation
import AVFoundation
import BLTNBoard
import Speech

extension MainViewController {
    
    // MARK: - Functions
    
    /**
     The Introduction card used while onboarding.
     - Returns: A BLTNPageItem with the Introduction configuration.
     */
    
    internal func onboardingIntroduction() -> BLTNPageItem {
        
        let card = onboardingCommonCard(withTitle: "Welcome",
                                        isDismissable: true)
        
        card.descriptionText = "I am the coolest tech assistant for people with visual impairments."
        card.actionButtonTitle = "Next"
        card.image = UIImage(named: "iconWelcome")
        card.next = self.onboardingMicrophoneAccess()
        
        card.actionHandler = { [unowned self] item in
            self.bulletinManager.displayNextItem()
        }
        
        return card
        
    }
    
    
    
    /**
     The Microphone Access card used while onboarding.
     - Returns: A BLTNPageItem with the Microphone Access configuration.
     */
    
    internal func onboardingMicrophoneAccess() -> BLTNPageItem {
        
        let card = onboardingCommonCard(withTitle: "Microphone Access",
                                        colorTheme: THColor.flatRed)
        
        card.descriptionText = "If you want me to help, you'll need to start by granting me access to your microphone."
        card.actionButtonTitle = "Grant Access"
        card.image = UIImage(named: "iconMicrophoneAccess")
        card.next = self.onboardingSpeechRecognition()
        
        card.actionHandler = { [unowned self] item in
            
            AVAudioSession.sharedInstance().requestRecordPermission({ authorized in
                
                guard authorized else {
                    
                    // Open the application settings.
                    self.openAppSettings()
                    return
                    
                }
                
                // Dispatch to the main thread for UI updates.
                DispatchQueue.main.async {
                    self.bulletinManager.displayNextItem()
                }
                
            })
            
        }
        
        return card
        
    }
    
    
    
    /**
     The SpeechRecognition card used while onboarding.
     - Returns: A BLTNPageItem with the SpeechRecognition configuration.
     */
    
    internal func onboardingSpeechRecognition() -> BLTNPageItem {
        
        let card = onboardingCommonCard(withTitle: "Speech Recognition",
                                        colorTheme: THColor.flatPurple)
        
        card.descriptionText = "I also can't do much without being able to recognize your speech!"
        card.actionButtonTitle = "Grant Access"
        card.image = UIImage(named: "iconSpeechRecognition")
        card.next = self.onboardingCameraAccess()
        
        card.actionHandler = { [unowned self] item in
            
            SFSpeechRecognizer.requestAuthorization { status in
                
                switch (status) {
                    
                case .denied, .notDetermined, .restricted:
                    
                    // Open the application settings.
                    self.openAppSettings()
                    
                    
                case .authorized:
                    
                    // Dispatch to the main thread for UI updates.
                    DispatchQueue.main.async {
                        self.bulletinManager.displayNextItem()
                    }
                    
                }
                
                
            }
            
        }
        
        return card
        
    }
    
    
    
    /**
     The Camera Access card used while onboarding.
     - Returns: A BLTNPageItem with the Camera Access configuration.
     */
    
    internal func onboardingCameraAccess() -> BLTNPageItem {
        
        let card = onboardingCommonCard(withTitle: "Camera Access",
                                        colorTheme: THColor.flatBlue)
        
        card.descriptionText = "Lastly, you'll have to grant me camera access if you want me to identify objects for you."
        card.actionButtonTitle = "Grant Access"
        card.image = UIImage(named: "iconCameraAccess")
        card.next = self.onboardingCompleted()
        
        card.actionHandler = { [unowned self] item in
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
                
                guard authorized else {
                    
                    // Open the application settings.
                    self.openAppSettings()
                    return
                    
                }
                
                // Dispatch to the main thread for UI updates.
                DispatchQueue.main.async {
                    self.bulletinManager.displayNextItem()
                }
                
            })
            
        }
        
        return card
        
    }
    
    
    
    /**
     The Setup Completed card used while onboarding.
     - Returns: A BLTNPageItem with the Setup Completed configuration.
     */
    
    internal func onboardingCompleted() -> BLTNPageItem {
        
        let card = onboardingCommonCard(withTitle: "Setup Complete")
        
        card.descriptionText = "Your setup is now complete. I hope you will enjoy this journey!"
        card.actionButtonTitle = "Get Started"
        card.image = UIImage(named: "iconSetupComplete")
        
        card.actionHandler = { [unowned self] item in
            // TODO: Uncomment line below in production releases.
            // UserDefaults.standard.set(true, forKey: THKey.onboardingCompleted)
            self.bulletinManager.dismissBulletin()
        }
        
        return card
        
    }
    
    
    
    /**
     The common card used while onboarding.
     - Returns: A BLTNPageItem with the common card configurations.
     */
    
    internal func onboardingCommonCard(withTitle title: String,
                                       colorTheme: UIColor = THColor.green,
                                       isDismissable: Bool = false) -> BLTNPageItem {
        
        let card = BLTNPageItem(title: title)
        
        // Title
        card.appearance.titleFontDescriptor = UIFontDescriptor(fontAttributes: [.name: "Nunito-SemiBold"])
        
        // Description
        card.appearance.descriptionFontSize = 17
        card.appearance.descriptionFontDescriptor = UIFontDescriptor(fontAttributes: [.name: "Nunito-Regular"])
        
        // Buttons
        card.appearance.actionButtonColor = colorTheme
        card.appearance.alternativeButtonTitleColor = colorTheme
        card.appearance.buttonFontDescriptor = UIFontDescriptor(fontAttributes: [.name: "Nunito-Bold"])
        
        // Dismissability
        card.isDismissable = isDismissable
        card.requiresCloseButton = false
        
        return card
        
    }
    
    
    
    /**
     Retrives and opens the openSettingsURLString.
     */
    
    internal func openAppSettings() {
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("⚠️ Could not retrieve the settings URL.")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(settingsURL)
        }
        
    }
    
}
