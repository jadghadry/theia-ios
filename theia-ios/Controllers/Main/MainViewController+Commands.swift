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
     Runs a transcribed static command.
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
            
        // Command does not exist.
        default:
            synthesizer.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
}
