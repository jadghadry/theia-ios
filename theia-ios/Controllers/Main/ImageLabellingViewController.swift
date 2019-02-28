//
//  ImageLabellingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

class ImageLabellingViewController: ProcessingViewController {
    
    // MARK: - Lazy Properties
    
    private lazy var labelDetector: VisionImageLabeler = {
        
        // Retrieve the user-defined confidence threshold.
        let confidenceThreshold = UserDefaults.standard.float(forKey: THKey.confidenceThreshold)
        
        let options = VisionOnDeviceImageLabelerOptions()
            options.confidenceThreshold = confidenceThreshold
        
        return Vision.vision().onDeviceImageLabeler(options: options)
        
    }()
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     
     - Parameter visionImage: The VisionImage object to be processed.
     */
    
    override func process(_ visionImage: VisionImage) {
        
        self.labelDetector.process(visionImage, completion: { (labels, error) in
            
            // Check whether results were actually retrieved.
            guard let labels = labels, error == nil else {
                print("⚠️ There was an error processing the Image Labelling input.")
                return
            }
            
            // Get the list of processed objects sorted by their respective confidence levels.
            let processedObjectsDescription = labels.map({
                
                guard let confidence = $0.confidence?.floatValue else {
                    return "\($0.text) detected with unknown confidence."
                }
                
                return "\($0.text) detected with \(Int(confidence * 100))% confidence."
                
            }).joined(separator: "\n")
            
            // Update the displayed label text.
            self.displayedOutputText = labels.first?.text
            
            // Provide vocal feedback of the processed text.
            self.spokenOutputText = processedObjectsDescription
            
        })

    }

}
