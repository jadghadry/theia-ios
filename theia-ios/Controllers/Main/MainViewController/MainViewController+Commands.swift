//
//  MainViewController+Commands.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit

extension MainViewController {
    
    // MARK: - Functions
    
    /**
     Runs a static command, if available.
     Future updates to this method should include dynamic compatibility.
     */
    
    internal func runCommand() {
        
        // Check if a non-empty command was initiated.
        guard let command = self.command?.uppercased() else {
            return
        }
        
        let synthesizer = THSpeechSynthesizer.shared
        
        switch (command) {
            
        // Image processing and machine learning modules are deployed in order to read text.
        case let command where command.contains("TEXT"):
            self.performSegue(withIdentifier: "segueToTextRecognizer", sender: nil)
            
        // Image processing and machine learning modules are deployed in order to classify objects.
        case let command where command.contains("IDENTIFY"):
            self.performSegue(withIdentifier: "segueToImageClassifier", sender: nil)
            
        // Modify the confidence threshold value.
        case let command where command.contains("CONFIDENCE THRESHOLD"):
            self.modifySettings(forKey: THSettingsKey.confidenceThreshold, fromCommand: command)
            
        // Modify the speech rate value.
        case let command where command.contains("SPEECH RATE"):
            self.modifySettings(forKey: THSettingsKey.speechRate, fromCommand: command)
            
        // Command does not exist.
        default:
            synthesizer.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
    
    
    /**
     Modifies user settings according to a given command.
     
     - Parameter key: The key of the Theia parameter to change.
     - Parameter command: The command from which the numerical should be extracted.
     */
    
    internal func modifySettings(forKey key: String, fromCommand command: String) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // Check whether the invoked command contains a number.
        guard let extractedNumber = command.extractNumber() else {
            synthesizer.speak(text: "Could not extract value.")
            return
        }
        
        // Check if the extracted number falls between 1 and 100.
        guard (1...100).contains(extractedNumber) else {
            synthesizer.speak(text: "Please provide a value between 1 and 100%.")
            return
        }
        
        UserDefaults.standard.set(extractedNumber/100.0, forKey: key)
        synthesizer.speak(text: "Ok, done!")
        
    }
    
}
