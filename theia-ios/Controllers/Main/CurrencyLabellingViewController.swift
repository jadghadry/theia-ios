//
//  CurrencyLabellingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 2/16/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import UIKit
import CoreML
import Vision

class CurrencyLabellingViewController: ProcessingViewController {
    
    // MARK: - Lazy Properties
    
    @available(iOS 11.0, *)
    lazy var classificationRequest: VNCoreMLRequest = {
        
        do {
            let model = try VNCoreMLModel(for: LBPClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] (request, error) in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("⚠️ Failed to load Vision ML model: \(error)")
        }
        
    }()
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     
     - Parameter image: The UIImage object to be processed.
     */
    
    override func process(_ image: UIImage) {
        
        if #available(iOS 11.0, *) {
            self.updateClassifications(for: image)
        } else {
            print("⚠️ Custom classification requires iOS 11.0 or newer.")
        }
        
    }
    
    
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     
     - Parameter request: The VNRequest object to process.
     - Parameter error: The Error thrown by the classification process.
     */
    
    @available(iOS 11.0, *)
    func processClassifications(for request: VNRequest, error: Error?) {
        
        DispatchQueue.main.async {
            
            guard let results = request.results else {
                print("⚠️ \(error!.localizedDescription).")
                return
            }
            
            guard let classifications = results as? [VNClassificationObservation], !classifications.isEmpty else {
                print("⚠️ No currency recognized.")
                return
            }
            
            // Retrieve the classification result with the highest degree of confidence.
            let topClassification = classifications.first?.identifier
            
            // Update the displayed label text.
            self.displayedOutputText = topClassification
            
            // Provide vocal feedback of the processed text.
            self.spokenOutputText = topClassification
            
        }
        
    }
    
    
    
    /**
     Performs classification on the retrieved image object.
     
     - Parameter image: The UIImage object that will be fed to the VNCoreMLModel.
     */
    
    @available(iOS 11.0, *)
    func updateClassifications(for image: UIImage) {
        
        print("📃 Classifying...")
        
        // Retrieve a CGImagePropertyOrientation from the input image.
        guard let orientation = CGImagePropertyOrientation(image.imageOrientation) else {
            print("⚠️ Unable to retrieve the \(CGImagePropertyOrientation.self) from \(image).")
            return
        }
        
        // Retrieve a CIImage object from the input image.
        guard let ciImage = CIImage(image: image) else {
            print("⚠️ Unable to create a \(CIImage.self) object from \(image).")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                // Catch general image processing errors.
                print("⚠️ Failed to perform classification due to \(error.localizedDescription).")
            }
        }
    }
    
}
