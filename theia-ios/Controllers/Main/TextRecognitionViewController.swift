//
//  TextRecognitionViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/15/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit

class TextRecognitionViewController: ProcessingViewController {
    
    // MARK: - Optional Properties
    
    private lazy var textRecognizer: VisionTextRecognizer = {
        return Vision.vision().onDeviceTextRecognizer()
    }()
    
    
    
    // MARK: - Functions
    
    /**
     Performs OCR on the VisionImage input and extracts relevant text accordingly.
     
     - Parameter visionImage: The VisionImage object to be processed.
     */
    
    override func process(_ visionImage: VisionImage) {
        
        self.textRecognizer.process(visionImage, completion: { (result, error) in
            
            // Check whether results were actually retrieved.
            guard let result = result, error == nil else {
                print("⚠️ There was an error processing the Text Recognition input.")
                return
            }
            
            // Provide vocal feedback of the processed text.
            self.spokenOutputText = result.text
            
        })
        
    }

}
