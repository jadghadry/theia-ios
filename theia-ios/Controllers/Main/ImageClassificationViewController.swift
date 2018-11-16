//
//  ImageClassificationViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

class ImageClassificationViewController: CaptureSessionViewController {
    
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
            
            // Get the detected object with the highest confidence level.
            let highestConfidenceObject = results?.max(by: {
                $0.label > $1.label
            })
            
            self.processedText = highestConfidenceObject?.label ?? "Nothing detected"
            
            DispatchQueue.main.async {
                self.lblObjectDescription.text = self.processedText
            }
            
        })

    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpLabelDetector() {
        
        let vision = Vision.vision()
        let options = VisionLabelDetectorOptions(confidenceThreshold: 0.50)
        
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
