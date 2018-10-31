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
    
    /**
     Returns an instance of the same image with an upwards image orientation.
     This is particularly useful when taking a picture from the camera directly.
     */
    
    func fixImageOrientation() -> UIImage? {
        
        if (self.imageOrientation == .up) {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        // Apply generic transformations based on image orientation.
        switch self.imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi/2)
            
        default:
            break
            
        }
        
        // Apply transformations for mirrored-only orientations.
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
            
        }
        
        // Define the new context to draw the image from.
        if
            let quartzImage = self.cgImage,
            let context: CGContext = CGContext(data: nil,
                                              width: Int(self.size.width),
                                              height: Int(self.size.height),
                                              bitsPerComponent: quartzImage.bitsPerComponent,
                                              bytesPerRow: 0,
                                              space: quartzImage.colorSpace!,
                                              bitmapInfo: self.cgImage!.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if
                self.imageOrientation == UIImage.Orientation.left ||
                self.imageOrientation == UIImage.Orientation.leftMirrored ||
                self.imageOrientation == UIImage.Orientation.right ||
                self.imageOrientation == UIImage.Orientation.rightMirrored {
                
                context.draw(quartzImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
                
            } else {
                
                context.draw(quartzImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
            
        }
        
        return nil
    }
    
}
