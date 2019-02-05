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
    
    override func process(_ image: VisionImage) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        self.textRecognizer?.process(image, completion: { (result, error) in
            
            // Check whether there was an error in performing OCR on the image.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Check whether results were actually retrieved.
            guard let result = result else {
                print("⚠️ No text detected.")
                return
            }
            
            synthesizer.speak(text: result.text)
            print(result.text)
            
        })
        
    }
    
    
    
    /**
     Configures the MLKit text recognizer.
     */
    
    internal func setUpTextRecognizer() {
        self.textRecognizer = Vision.vision().onDeviceTextRecognizer()
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        super.setUpViewController()
        self.setUpTextRecognizer()
    }

}
