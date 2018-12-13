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
    
    internal func runCommand(_ command: String?) {
        
        // Check if a non-empty command was initiated.
        guard let command = command?.uppercased() else {
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
            self.modifyConfidenceThreshold(fromCommand: command)
            
        // Command does not exist.
        default:
            synthesizer.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
    
    
    /**
     Modifies the confidence threshold value according to a given command.
     
     - Parameter command: The command from which the confidence threshold value should be extracted.
     */
    
    internal func modifyConfidenceThreshold(fromCommand command: String) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // Extract the percentage value from the command.
        let nonDecimalDigits = CharacterSet.decimalDigits.inverted
        let extractedNumber = Float(command.components(separatedBy: nonDecimalDigits).joined())
        
        guard let confidenceThreshold = extractedNumber else {
            synthesizer.speak(text: "Invalid threshold.")
            return
        }
        
        guard (1...100).contains(confidenceThreshold) else {
            synthesizer.speak(text: "Please provide a value between 1 and 100%.")
            return
        }
        
        UserDefaults.standard.set(confidenceThreshold/100.0, forKey: THSettingsKey.confidenceThreshold)
        synthesizer.speak(text: "Done!")
        
    }
    
}
