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
        
        switch (command) {
            
        // Modify the confidence threshold value.
        case let command where command.contains("CONFIDENCE THRESHOLD"):
            self.modifyConfidenceThreshold(fromCommand: command)
            
        // Image processing modules are deployed in order to identify colors.
        case let command where command.contains("COLOR"):
            self.performSegue(withIdentifier: "segueToColorClassifier", sender: nil)
            
        // Image processing and machine learning modules are deployed in order to detect currency values.
        case let command where command.contains("CURRENCY"):
            self.performSegue(withIdentifier: "segueToCurrencyClassifier", sender: nil)
            
        // Image processing and machine learning modules are deployed in order to classify objects.
        case let command where command.contains("IDENTIFY"):
            self.performSegue(withIdentifier: "segueToImageClassifier", sender: nil)
            
        // Image processing and machine learning modules are deployed in order to read text.
        case let command where command.contains("TEXT"):
            self.performSegue(withIdentifier: "segueToTextRecognizer", sender: nil)
            
        // Command does not exist.
        default:
            THSpeechSynthesizer.shared.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
    
    
    /**
     Modifies the confidence threshold based on an invoked command.
     
     - Parameter command: The command from which the numerical should be extracted.
     */
    
    internal func modifyConfidenceThreshold(fromCommand command: String) {
        
        // Check whether the invoked command contains a number.
        guard let extractedNumber = command.extractNumber() else {
            THSpeechSynthesizer.shared.speak(text: "Could not extract value.")
            return
        }
        
        // Check if the extracted number falls between 25 and 100%.
        guard (25...100).contains(extractedNumber) else {
            THSpeechSynthesizer.shared.speak(text: "Please provide a value between 25 and 100%.")
            return
        }
        
        UserDefaults.standard.set(extractedNumber/100.0, forKey: THKey.confidenceThreshold)
        THSpeechSynthesizer.shared.speak(text: "Ok, done!")
        
    }
    
}
