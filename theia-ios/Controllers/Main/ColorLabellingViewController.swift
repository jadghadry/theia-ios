//
//  ColorLabellingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 3/22/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import UIKit

class ColorLabellingViewController: ProcessingViewController {
    
    // MARK: - Lazy Properties
    
    private lazy var context = CIContext(options: [.workingColorSpace: kCFNull])
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage input and extracts objects that meet the user-defined confidence threshold.
     
     - Parameter image: The UIImage object to be processed.
     */
    
    override func process(_ image: UIImage) {
        
        guard let averageColor = self.retrieveAverageColor(fromImage: image) else {
            return
        }
        
        let colorName = self.getName(ofColor: averageColor)
        
        self.displayedOutputText = colorName
        self.spokenOutputText = colorName
        
        // Update the background color of the backdrop view.
        self.viewBackdrop?.backgroundColor = averageColor
        
    }
    
    
    
    /**
     Retrieves the color name that best describes the input.
     
     - Parameter color: The color to name.
     */
    
    private func getName(ofColor color: UIColor) -> String? {
        
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var colorName: String = String.init()
        
        // Retrieve the input color components.
        guard let colorComponents = color.cgColor.components else {
            print("⚠️ There was an error retrieving the input color components")
            return nil
        }
        
        // Iterate through the dictionary of colors.
        for entry in THColor.colorsDictionary {
            
            // Retrieve the color and value components.
            guard let valueComponents = entry.value.cgColor.components else {
                print("⚠️ There was an error retrieving the value color components")
                return nil
            }
            
            var distance: CGFloat = 0
            
            // Compute the color distance.
            for i in 0...2 {
                distance = distance + pow(colorComponents[i] - valueComponents[i], 2)
            }
            
            if distance < minDistance {
                minDistance = distance
                colorName = entry.key
            }
            
        }
        
        return colorName
        
    }
    
    
    
    /**
     Retrieves the average color from a particular image input.
     
     - Parameter image: The UIImage to be processed.
     */
    
    private func retrieveAverageColor(fromImage image: UIImage) -> UIColor? {
        
        // Convert the input to a CIImage.
        guard let inputImage = CIImage(image: image) else {
            return nil
        }
        
        // Create a CIVector object relevant to coordinates of the input image.
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        
        // Retrieve the CIAreaAverage filter.
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else {
            return nil
        }
        
        // Retrieve the CIImage output after applying the filter.
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // Render the bitmap.
        self.context.render(outputImage,
                            toBitmap: &bitmap,
                            rowBytes: 4,
                            bounds: bounds,
                            format: .RGBA8,
                            colorSpace: nil)
        
        return UIColor(R: CGFloat(bitmap[0]), G: CGFloat(bitmap[1]), B: CGFloat(bitmap[2]), A: CGFloat(bitmap[3]))
        
    }
    
}

