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
    
    // MARK: - Outlets
    
    @IBOutlet weak var lblObjectDescription: UILabel!
    
    
    
    // MARK: - Optional Properties
    
    var labelDetector: VisionLabelDetector?
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     */
    
    override func processVisionImage(_ image: VisionImage) {
        
        self.labelDetector?.detect(in: image, completion: { [unowned self] (results, error) in
            
            // Check whether there was an error in labeling the image.
            if let error = error {
                THSpeechSynthesizer.shared.speak(text: error.localizedDescription)
                return
            }
            
            // Get the list of processed object sorted by their respective confidence levels.
            let processedObjectsDescription = results?.sorted(by:{
                $0.confidence > $1.confidence
            }).map({
                "\($0.label) detected with \(Int($0.confidence * 100))% confidence."
            }).joined(separator: "\n")
            
            self.processedText = processedObjectsDescription
            
            // Get the detected object with the highest confidence level.
            let highestConfidenceObject = results?.max(by: {
                $0.confidence < $1.confidence
            })
            
            DispatchQueue.main.async {
                self.lblObjectDescription.text = highestConfidenceObject?.label ?? "Nothing Detected"
            }
            
        })

    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpLabelDetector() {
        
        let vision = Vision.vision()
        let options = VisionLabelDetectorOptions(confidenceThreshold: 0.80)
        
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
