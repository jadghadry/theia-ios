//
//  String.swift
//  theia-ios
//
//  Created by Jad Ghadry on 12/15/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - Functions
    
    /**
     Extracts all numbers from a given string and joins them into a single value.
     */
    
    func extractNumber() -> Float? {
        
        let nonDecimalDigits = CharacterSet.decimalDigits.inverted
        let extractedNumber = Float(self.components(separatedBy: nonDecimalDigits).joined())
        
        return extractedNumber
        
    }
    
}
