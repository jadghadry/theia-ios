//
//  ImageLabellingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

class ImageLabellingViewController: CaptureSessionViewController {
    
    // MARK: - Optional Properties
    
    var labelDetector: VisionLabelDetector?
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     */
    
    override func process(_ image: VisionImage) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        self.labelDetector?.detect(in: image, completion: { (results, error) in
            
            // Check whether there was an error in labeling the image.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Check whether results were actually retrieved.
            guard let results = results, !results.isEmpty else {
                print("⚠️ No Objects Detected.")
                return
            }
            
            // Get the list of processed objects sorted by their respective confidence levels.
            let processedObjectsDescription = results.sorted(by:{
                $0.confidence > $1.confidence
            }).map({
                "\($0.label) detected with \(Int($0.confidence * 100))% confidence."
            }).joined(separator: "\n")
            
            // Utter and print the list of processed objects.
            synthesizer.speak(text: processedObjectsDescription)
            print(processedObjectsDescription)
            
        })

    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpLabelDetector() {
        
        // Retrieve the user-defined confidence threshold.
        let confidenceThreshold = UserDefaults.standard.float(forKey: THKey.confidenceThreshold)
        
        let vision = Vision.vision()
        let options = VisionLabelDetectorOptions(confidenceThreshold: confidenceThreshold)
        
        self.labelDetector = vision.labelDetector(options: options)
        
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        super.setUpViewController()
        self.setUpLabelDetector()
    }

}
