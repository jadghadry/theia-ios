//
//  THUtilities.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/14/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import AVFoundation
import Foundation

class THUtilities {
    
    // MARK: - Computed Properties
    
    /**
     Retrieves the actual image orientation as taken by the back camera.
     */
    
    static var imageOrientation: UIImage.Orientation {
        
        get {
            
            let deviceOrientation = UIDevice.current.orientation
            
            switch (deviceOrientation) {
                
            case .portrait:
                return .right
            case .portraitUpsideDown:
                return .left
            case .landscapeLeft:
                return .up
            case .landscapeRight:
                return .down
            case .faceDown, .faceUp, .unknown:
                return .up
                
            }
            
        }
        
    }
    
    
    
    // MARK: - Functions
    
    /**
     Returns true if the app was launched for the very first time by the user.
     Note that this value resets only if the app is uninstalled from the device.
     */
    
    static func isFirstApplicationLaunch() -> Bool {
        
        if UserDefaults.standard.bool(forKey: THKey.notFirstLaunch) {
            return false
        }
        
        UserDefaults.standard.set(true, forKey: THKey.notFirstLaunch)
        return true
        
    }
    
    
    
    /**
     Returns the origin of the located image as defined by the EXIF specifications.
     
     - Parameter imageOrientation: The intended display orientation for an image.
     */
    
    static func visionImageOrientation(from imageOrientation: UIImage.Orientation) -> VisionDetectorImageOrientation {
        
        switch (imageOrientation) {
            
        case .up:
            return .topLeft
        case .down:
            return .bottomRight
        case .left:
            return .leftBottom
        case .right:
            return .rightTop
        case .upMirrored:
            return .topRight
        case .downMirrored:
            return .bottomLeft
        case .leftMirrored:
            return .leftTop
        case .rightMirrored:
            return .rightBottom
            
        }
        
    }
    
}
