//
//  UIImage+TFLite.swift
//  theia-ios
//
//  Created by Jad Ghadry on 2/16/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import Foundation



// MARK: - Constants

private enum Constants {
    
    static let alphaComponentBaseOffset = 4
    static let alphaComponentModuloRemainder = 3
    
}



extension UIImage {
    
    // MARK: - Functions
    
    /**
     Returns the scaled image data representation of the image from the given values.
     
     - Parameter size: Size to scale the image to (i.e. expected size of the image in the trained model).
     - Parameter componentsCount: Number of color components for the image.
     - Parameter batchSize: Batch size for the image.
     
     - Returns: The scaled image data or nil if the image could not be scaled.
     */
    
    public func scaledImageData(with size: CGSize,
                                componentsCount newComponentsCount: Int,
                                batchSize: Int) -> Data? {
        
        guard let cgImage = self.cgImage, cgImage.width > 0, cgImage.height > 0 else {
            return nil
        }
        
        let oldComponentsCount = cgImage.bytesPerRow / cgImage.width
        guard newComponentsCount <= oldComponentsCount else {
            return nil
        }
        
        guard let imageData = self.imageData(from: cgImage, size: size, componentsCount: oldComponentsCount) else {
            return nil
        }
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        let bytesCount = width * height * newComponentsCount * batchSize
        var scaledBytes = [UInt8](repeating: 0, count: bytesCount)
        
        // Extract the RGB(A) components from the scaled image data while ignoring the alpha component.
        var pixelIndex = 0
        for pixel in imageData.enumerated() {
            
            let offset = pixel.offset
            let isAlphaComponent = (offset % Constants.alphaComponentBaseOffset) == Constants.alphaComponentModuloRemainder
            
            guard !isAlphaComponent else {
                continue
            }
            
            scaledBytes[pixelIndex] = pixel.element
            pixelIndex += 1
            
        }
        
        return Data(bytes: scaledBytes)
        
    }
    
    
    
    /**
     Returns the scaled image data representation of the image from the given values.
     
     - Parameter image: The image to extract the data from.
     - Parameter size: Size of the input image.
     - Parameter componentsCount: The number of components within the image.
     
     - Returns: The image data or nil.
     */
    
    private func imageData(from image: CGImage,
                           size: CGSize,
                           componentsCount: Int) -> Data? {
                
        let width = Int(size.width)
        let height = Int(size.height)
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: image.bitsPerComponent, bytesPerRow: componentsCount * width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue) else {
                return nil
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()?.dataProvider?.data as Data?
        
    }
    
}
