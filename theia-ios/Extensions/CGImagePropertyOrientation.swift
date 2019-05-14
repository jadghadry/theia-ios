//
//  CGImagePropertyOrientation.swift
//  theia-ios
//
//  Created by Jad Ghadry on 2/28/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import Foundation
import ImageIO

extension CGImagePropertyOrientation {
    
    // MARK: - Initializers
   
    init?(_ orientation: UIImage.Orientation) {
        
        switch orientation {
            
        case .up:
            self = .up
        
        case .upMirrored:
            self = .upMirrored
        
        case .down:
            self = .down
        
        case .downMirrored:
            self = .downMirrored
        
        case .left:
            self = .left
        
        case .leftMirrored:
            self = .leftMirrored
        
        case .right:
            self = .right
        
        case .rightMirrored:
            self = .rightMirrored
            
        @unknown default:
            return nil
        }
        
    }
    
}
