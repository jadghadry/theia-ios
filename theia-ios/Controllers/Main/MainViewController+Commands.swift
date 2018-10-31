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
    
    internal func runCommand(_ command: String?) {
        
        // Check if a non-empty command was initiated.
        guard let command = command?.uppercased() else {
            return
        }
        
        switch(command) {
            
        case "READ TEXT":
            /*
             This represents one of the core features of the application.
             Image processing and machine learning modules will be deployed in order read text from a static image.
             */
            self.takePicture()
            
        case "PROCESS BILL":
            /*
             This represents one of the core features of the application.
             Image processing and machine learning modules will be deployed in order to analyze bills from a static image.
             */
            break
            
        default:
            self.speak(text: "Command not found")
            
        }
        
        self.command = nil
        
    }
    
}
