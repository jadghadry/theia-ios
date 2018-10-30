//
//  JGBaseViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import Foundation

extension JGBaseViewController {
    
    // MARK: - Functions
    
    /**
     Returns a UIAlertController with a title, message and dismissive button.
     
     - Parameter title: The title of the UIAlertController.
     - Parameter viewController: The message included in the UIAlertController.
     - Parameter dismissButtonTitle: The title of the dismissive button included in the UIAlertController.
     - Returns: A UIAlertController constructed with the user-defined parameters.
     */
    
    open func createErrorAlert(withAlertTitle title: String,
                               alertMessage message: String,
                               andDismissButtonTitle dismissButtonTitle: String) -> UIAlertController {
        
        let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(dismissAction)
        
        return alertController
        
    }
    
}
