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
            
        case let command where command.contains("INTRODUCE"):
            let text = "Hello there, my name is Theia, a digital assistant for the visually impaired. --- I leverage the power of AI and Image Processing in order to provide a handful of features. --- Also, I was originally the Goddess of sight. --- The shining ether of the bright, but these guys managed to stuff me inside a mobile app!"
            synthesizer.speak(text: text, rate: 0.48)
            
        case let command where command.contains("FEATURES"):
            let text = "Definitely! --- So far, I can understand specific audio commands and accordingly provide vocal feedback. --- These commands include real-time OCR and image classification. --- In other words, I can read any bit of digital text and describe the contents of a particular image."
            synthesizer.speak(text: text, rate: 0.48)
            
        case let command where command.contains("TEXT"):
            /*
             Image processing and machine learning modules are deployed in order to read text from a static image.
             */
            self.performSegue(withIdentifier: "segueToTextRecognizer", sender: nil)
            
        case let command where command.contains("IDENTIFY"):
            /*
             Image processing and machine learning modules are deployed in order to classify objects from a static image.
             */
            self.performSegue(withIdentifier: "segueToImageClassifier", sender: nil)
            
        default:
            synthesizer.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
}
