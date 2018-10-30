//
//  UIImage.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import Foundation

extension UIImage {
    
    // MARK: - Functions
    
    func fixImageOrientation() -> UIImage? {
        
        if (self.imageOrientation == .up) {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if (self.imageOrientation == .left || self.imageOrientation == .leftMirrored) {
            // Orientations defined by .left or .leftMirrored
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        
        } else if (self.imageOrientation == .right || self.imageOrientation == .rightMirrored) {
            // Orientations defined by .right or .rightMirrored
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0))
            
        } else if (self.imageOrientation == .down || self.imageOrientation == .downMirrored) {
            // Orientations defined by .down or .downMirrored
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        } else if (self.imageOrientation == .upMirrored || self.imageOrientation == .downMirrored) {
            // Orientations defined by .upMirrored or .downMirrored
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        } else if (self.imageOrientation == .leftMirrored || self.imageOrientation == .rightMirrored) {
            // Orientations defined by .leftMirrored or .rightMirrored
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        // Define the new context to draw the image from.
        if let context: CGContext = CGContext(data: nil,
                                              width: Int(self.size.width),
                                              height: Int(self.size.height),
                                              bitsPerComponent: self.cgImage!.bitsPerComponent,
                                              bytesPerRow: 0,
                                              space: self.cgImage!.colorSpace!,
                                              bitmapInfo: self.cgImage!.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if (self.imageOrientation == UIImage.Orientation.left ||
                self.imageOrientation == UIImage.Orientation.leftMirrored ||
                self.imageOrientation == UIImage.Orientation.right ||
                self.imageOrientation == UIImage.Orientation.rightMirrored) {
                
                context.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
                
            } else {
                
                context.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
                
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
            
        }
        
        return nil
    }
    
}
