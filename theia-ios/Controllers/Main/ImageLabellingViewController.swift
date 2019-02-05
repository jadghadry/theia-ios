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
    
    @IBOutlet weak var lblProcessedObject: UILabel!
    @IBOutlet weak var viewBackdrop: UIView!
    
    
    
    // MARK: - Optional Properties
    
    var labelDetector: VisionImageLabeler?
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     */
    
    override func process(_ image: VisionImage) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        self.labelDetector?.process(image, completion: { (labels, error) in
            
            // Check whether there was an error in labeling the image.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Check whether results were actually retrieved.
            guard let labels = labels, !labels.isEmpty else {
                print("⚠️ No Objects Detected.")
                return
            }
            
            // Get the list of processed objects sorted by their respective confidence levels.
            let processedObjectsDescription = labels.map({
                
                guard let confidence = $0.confidence?.floatValue else {
                    return "\($0.text) detected with unknown confidence."
                }
                
                return "\($0.text) detected with \(Int(confidence * 100))% confidence."
                
            }).joined(separator: "\n")
            
            // Utter and print the list of processed objects.
            synthesizer.speak(text: processedObjectsDescription)
            print(processedObjectsDescription)
            
            // Get the object identified with the maximum confidence.
            let maxConfidenceObject = labels.first
            
            // Modify the label to output the object detected with the highest level of confidence.
            self.lblProcessedObject.text = maxConfidenceObject?.text
            
            // Hide the backdrop view in case no objects were detected.
            self.viewBackdrop.isHidden = maxConfidenceObject == nil
            
        })

    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpLabelDetector() {
        
        // Retrieve the user-defined confidence threshold.
        let confidenceThreshold = UserDefaults.standard.float(forKey: THKey.confidenceThreshold)
        
        let options = VisionOnDeviceImageLabelerOptions()
            options.confidenceThreshold = confidenceThreshold
        
        self.labelDetector = Vision.vision().onDeviceImageLabeler(options: options)
        
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        super.setUpViewController()
        self.setUpLabelDetector()
    }

}
