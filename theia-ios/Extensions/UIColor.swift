//
//  UIColor.swift
//  theia-ios
//
//  Created by Jad Ghadry on 5/11/19.
//  Copyright © 2019 Jad Ghadry. All rights reserved.
//

import Foundation

extension UIColor {
    
    // MARK: - Functions
    
    /**
     Retrieves the color name that best describes the color object.
     */
    
    public func getName() -> String? {
        
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var colorName: String = String.init()
        
        // Retrieve the input color components.
        guard let colorComponents = self.cgColor.components else {
            print("⚠️ There was an error retrieving the input color components")
            return nil
        }
        
        // Iterate through the dictionary of colors.
        for entry in UIColor.colorsDictionary {
            
            // Retrieve the color components.
            guard let valueComponents = entry.value.cgColor.components else {
                print("⚠️ There was an error retrieving the value color components")
                return nil
            }
            
            // Reset the color distance.
            var distance: CGFloat = 0
            
            // Compute the new distance value.
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
    
}
