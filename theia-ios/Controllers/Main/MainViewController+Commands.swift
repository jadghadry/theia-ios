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
        
        switch (command) {
            
        case "READ TEXT":
            /*
             Image processing and machine learning modules are deployed in order read text from a static image.
             */
            self.performSegue(withIdentifier: "segueToTextRecognizer", sender: nil)
            
        case "CLASSIFY IMAGE":
            /*
             Image processing and machine learning modules are deployed in order read text from a static image.
             */
            self.performSegue(withIdentifier: "segueToImageClassifier", sender: nil)
            
        default:
            THSpeechSynthesizer.shared.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
}
