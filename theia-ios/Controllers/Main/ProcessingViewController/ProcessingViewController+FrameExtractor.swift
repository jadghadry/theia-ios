//
//  ProcessingViewController+FrameExtractor.swift
//  theia-ios
//
//  Created by Jad Ghadry on 12/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import Foundation

extension ProcessingViewController {
    
    // MARK: - Functions
    
    /**
     Returns an optional UIImage from a CMSampleBuffer frame.
     
     - Parameter sampleBuffer: The CMSampleBuffer to be converted.
     */
    
    internal func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer?) -> UIImage? {
        
        // Check if the sampleBuffer is nil.
        guard let sampleBuffer = sampleBuffer else {
            print("⚠️ the sample buffer input is nil.")
            return nil
        }
        
        // Transform the CMSampleBuffer to a CVImageBuffer.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("⚠️ Could not retrieve a CVImageBuffer object.")
            return nil
        }
        
        // Create a CIImage from the imageBuffer object.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Create a CIContext object.
        let context = CIContext()
        
        // Get a CGImage from the CIContext.
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("⚠️ Could not create a CGImage from the input CIImage.")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
    
    
    /**
     Returns an optional UIImage from the sampleBufferToProcess class instance.
     */
    
    internal func imageFromSampleBuffer() -> UIImage? {
        return self.imageFromSampleBuffer(self.sampleBufferToProcess)
    }
    
    
    
    /**
     Returns a VisionImage object to process using a CMSampleBuffer input.
     Also fixes the orientation of the image according to the orientation of the device.
     */
    
    internal func visionImageToProcess(fromImage image: UIImage) -> VisionImage? {
        
        // Modify the orientation of the retrieved buffer before sending it to processing.
        let imageOrientation = THUtilities.imageOrientation
        let visionOrientation = THUtilities.visionImageOrientation(from: imageOrientation)
        
        let customMetadata = VisionImageMetadata()
            customMetadata.orientation = visionOrientation
        
        let visionImage = VisionImage(image: image)
            visionImage.metadata = customMetadata
        
        return visionImage
        
    }
    
}



// MARK: - THFrameExtractorDelegate Extension

extension ProcessingViewController: THFrameExtractorDelegate {
    
    func didCaptureSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        self.sampleBufferToProcess = sampleBuffer
    }
    
}
