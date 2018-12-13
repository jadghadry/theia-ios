//
//  CaptureSessionViewController+Processing.swift
//  theia-ios
//
//  Created by Jad Ghadry on 12/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import Foundation

extension CaptureSessionViewController {
    
    // MARK: - Functions
    
    /**
     Returns an optional UIImage from a CMSampleBuffer frame.
     
     - Parameter sampleBuffer: The CMSampleBuffer to be converted.
     */
    
    internal func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        
        // Transform the CMSampleBuffer to a CVImageBuffer.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        // Create a CIImage from the imageBuffer object.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Create a CIContext object.
        let context = CIContext()
        
        // Get a CGImage from the CIContext.
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
    
    
    /**
     Retrieves a VisionImage object to process from a CMSampleBuffer.
     Also fixes the orientation of the image according to the orientation of the device.
     */
    
    internal func imageToProcess() -> VisionImage? {
        
        // Retrieve the CMSampleBuffer to process.
        guard let sampleBuffer = self.sampleBufferToProcess else {
            print("⚠️ No buffer was retrieved for processing.")
            return nil
        }
        
        // Retrieve a UIImage from the CMSampleBuffer object.
        guard let image = imageFromSampleBuffer(sampleBuffer) else {
            print("⚠️ Could not retrieve a UIImage from the CMSampleBuffer.")
            return nil
        }
        
        // Modify the orientation of the retrieved buffer before sending it to processing.
        let imageOrientation = THHelpers.imageOrientation()
        let visionOrientation = THHelpers.visionImageOrientation(from: imageOrientation)
        
        let customMetadata = VisionImageMetadata()
            customMetadata.orientation = visionOrientation
        
        let visionImage = VisionImage(image: image)
            visionImage.metadata = customMetadata
        
        return visionImage
        
    }
    
}
