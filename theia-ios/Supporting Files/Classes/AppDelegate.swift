//
//  AppDelegate.swift
//  theia-ios
//
//  Created by Jad Ghadry on 9/29/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    
    
    // MARK: - Functions
    
    fileprivate func configureFirebase() {
        FirebaseApp.configure()
    }
    
    
    
    fileprivate func configureTheia() {
        
        if THUtilities.isFirstApplicationLaunch() {
            UserDefaults.standard.set(0.5, forKey: THKey.confidenceThreshold)
        }
        
    }
    
}



// MARK: - UIApplicationDelegate Extension

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // App configurations.
        self.configureFirebase()
        self.configureTheia()
        
        return true
        
    }
    
}
