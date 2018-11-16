//
//  TextRecognitionViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/15/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit

class TextRecognitionViewController: CaptureSessionViewController {
    
    // MARK: - Optional Properties
    
    var textRecognizer: VisionTextRecognizer?
    
    
    
    // MARK: - Functions
    
    /**
     Performs OCR on the VisionImage input and extracts relevant text accordingly.
     */
    
    override func processVisionImage(_ image: VisionImage) {
        
        self.textRecognizer?.process(image, completion: { [unowned self] result, error in
            
            // Check whether there was an error in performing OCR on the image.
            if let error = error {
                THSpeechSynthesizer.shared.speak(text: error.localizedDescription)
                return
            }
            
            if let result = result {
                self.processedText = result.text
                print(result.text)
            }
            
        })
        
    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpTextRecognizer() {
        let vision = Vision.vision()
        self.textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        super.setUpViewController()
        self.setUpTextRecognizer()
    }

}
