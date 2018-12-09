//
//  CaptureSessionViewController+Gestures.swift
//  theia-ios
//
//  Created by Jad Ghadry on 12/9/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import AVFoundation
import UIKit

extension CaptureSessionViewController {
    
    // MARK: - Selectors
    
    /**
     Dismisses the view and removes it from the view hierarchy.
     */
    
    @objc func dismissView(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /**
     Processes a given VisionImage input depending on the invoked user command.
     */
    
    @objc func processFrame(_ sender: UITapGestureRecognizer) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // WARNING: '_BeginSpeaking: couldn't begin playback'.
        if synthesizer.isSpeaking() {
            synthesizer.stopSpeaking()
            return
        }
        
        guard let image = self.imageToProcess else {
            print("⚠️ No image was provided for processing.")
            return
        }
        
        // If an image was retrieved, send it to processing.
        self.process(image)
        
    }
    
    
    
    /**
     If available, turns on the device's torch.
     */
    
    @objc internal func turnOnTorch() {
        self.toggleTorch(true)
    }
    
    
    
    /**
     If available, turns off the device's torch.
     */
    
    @objc internal func turnOffTorch() {
        self.toggleTorch(false)
    }
    
    
    
    // MARK: - Functions

    /**
     Adds a UISwipeGestureRecognizer that dismisses the view.
     */
    
    internal func setUpDismissSwipeGesture() {
        
        let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .down
            swipeGesture.addTarget(self, action: #selector(self.dismissView(_ :)))
        
        self.view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    
    /**
     Adds a UITapGestureRecognizer that processes a VisionImage input.
     */
    
    internal func setUpImageProcessingTapGesture() {
        
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 2
            tapGesture.addTarget(self, action: #selector(self.processFrame(_ :)))
        
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
    /**
     Adds a UISwipeGestureRecognizer to the view.
     */
    
    internal func setUpTorchActivationSwipeGesture() {
        
        let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .up
            swipeGesture.numberOfTouchesRequired = 2
            swipeGesture.addTarget(self, action: #selector(self.turnOnTorch))
        
        self.view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    
    /**
     Adds a UISwipeGestureRecognizer to the view.
     */
    
    internal func setUpTorchDeactivationSwipeGesture() {
        
        let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .down
            swipeGesture.numberOfTouchesRequired = 2
            swipeGesture.addTarget(self, action: #selector(self.turnOffTorch))
        
        self.view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    
    /**
     If available, toggles the torch of the device according to an input boolean parameter.
     
     - Parameter on: A boolean parameter that determines whether the torch should be toggled on or off.
     */
    
    internal func toggleTorch(_ on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        if device.hasTorch {
            
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
                
            } catch {
                print("🔦 Torch could not be used.")
            }
            
        } else {
            print("🔦 Torch is not available.")
        }
        
    }

}
