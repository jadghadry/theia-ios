//
//  CurrencyLabellingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 2/16/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import UIKit
import FirebaseMLCommon



// MARK: - Constants

private enum Constants {
    
    // Labels
    static let labelsFilename = "lbp_currency_labels"
    static let labelsExtension = "txt"
    static let labelsSeparator = "\n"
    
    // Model
    static let localModelFilename = "lbp_currency_detector"
    static let modelExtension = "tflite"
    
    // Model Dimensions
    static let dimensionBatchSize: NSNumber = 1
    static let dimensionImageWidth: NSNumber = 224
    static let dimensionImageHeight: NSNumber = 224
    static let dimensionComponents: NSNumber = 3
    static let inputDimensions = [dimensionBatchSize, dimensionImageWidth, dimensionImageHeight, dimensionComponents]
    
    static let modelInputIndex: UInt = 0
    static let modelElementType: ModelElementType = .uInt8
    
}



class CurrencyLabellingViewController: CaptureSessionViewController {
    
    // MARK: - Properties
    
    let modelInputOutputOptions = ModelInputOutputOptions()
    
    
    
    // MARK: - Optional Properties
    
    var modelInterpreter: ModelInterpreter?
    
    
    
    // MARK: - Lazy Properties
    
    private lazy var labels: [String] = {
        
        guard let labelsFilePath = Bundle.main.path(forResource: Constants.labelsFilename, ofType: Constants.labelsExtension) else {
            print("⚠️ Failed to get the labels file path.")
            return []
        }
        
        let encoding = String.Encoding.utf8.rawValue
        let contents = try! NSString(contentsOfFile: labelsFilePath, encoding: encoding)
        
        return contents.components(separatedBy: Constants.labelsSeparator).filter({
            return !$0.isEmpty
        })
        
    }()
    
    private lazy var outputDimensions = [Constants.dimensionBatchSize, NSNumber(value: labels.count)]
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     
     - Parameter image: The UIImage object to be processed.
     */
    
    override func process(_ image: UIImage) {
        
    }
    
    
    
    /**
     Retrieves the scaled image data required for the model interpreter.
     */
    
    private func scaledImageData(from image: UIImage) -> Data? {
        
        let batchSize = Constants.dimensionBatchSize.intValue
        let componentsCount = Constants.dimensionComponents.intValue
        
        let imageWidth = Constants.dimensionImageWidth.doubleValue
        let imageHeight = Constants.dimensionImageHeight.doubleValue
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        
        guard let scaledImageData = image.scaledImageData(with: imageSize, componentsCount: componentsCount, batchSize: batchSize) else {
            print("⚠️ Failed to scale image to \(imageSize).")
            return nil
        }
        
        return scaledImageData
        
    }
    
    
    
    /**
     Configures the MLKit model interpreter with the required options.
     */
    
    internal func setUpModelInterpreter() {
        
        let modelManager = ModelManager.modelManager()
        
        do {
            
            // Define the input and output formats relevant to the model.
            try self.modelInputOutputOptions.setInputFormat(index: Constants.modelInputIndex,
                                                            type: Constants.modelElementType,
                                                            dimensions: Constants.inputDimensions)
            try self.modelInputOutputOptions.setOutputFormat(index: Constants.modelInputIndex,
                                                             type: Constants.modelElementType,
                                                             dimensions: outputDimensions)
            
            guard let localModelFilePath = Bundle.main.path(forResource: Constants.localModelFilename, ofType: Constants.modelExtension) else {
                print("⚠️ Failed to get the local model file path.")
                return
            }
            
            // Register the local TFLite model.
            let localModelSource = LocalModelSource(name: Constants.localModelFilename,
                                                    path: localModelFilePath)
            
            modelManager.register(localModelSource)
            
            let modelOptions = ModelOptions(cloudModelName: nil,
                                            localModelName: Constants.localModelFilename)
            
            // Set the modelInterpreter object.
            self.modelInterpreter = ModelInterpreter.modelInterpreter(options: modelOptions)
            
        } catch let error as NSError {
            print("⚠️ Failed to load the model due to \(error.localizedDescription).")
            return
        }
        
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        super.setUpViewController()
        self.setUpModelInterpreter()
    }
    
}
