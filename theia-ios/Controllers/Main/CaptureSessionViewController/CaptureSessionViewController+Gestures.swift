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
    
    @objc func processSampleBuffer(_ sender: UITapGestureRecognizer) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // WARNING: _BeginSpeaking: couldn't begin playback.
        if synthesizer.isSpeaking() {
            synthesizer.stopSpeaking()
            return
        }
        
        // Retrieve a VisionImage to process.
        guard let visionImage = visionImageToProcess() else {
            print("⚠️ Could not retrieve a VisionImage object to process.")
            return
        }
        
        self.process(visionImage)
        
    }
    
    
    
    /**
     If available, turns on the device's torch.
     */
    
    @objc internal func turnOnTorch(_ sender: UISwipeGestureRecognizer) {
        self.toggleTorch(true)
    }
    
    
    
    /**
     If available, turns off the device's torch.
     */
    
    @objc internal func turnOffTorch(_ sender: UISwipeGestureRecognizer) {
        self.toggleTorch(false)
    }
    
    
    
    // MARK: - Functions

    /**
     Adds a UISwipeGestureRecognizer instance used to dismiss the view.
     */
    
    internal func setUpDismissSwipeGesture() {
        
        let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .down
            swipeGesture.addTarget(self, action: #selector(self.dismissView(_ :)))
        
        self.view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    
    /**
     Adds a UITapGestureRecognizer instance used to process a VisionImage input.
     */
    
    internal func setUpImageProcessingTapGesture() {
        
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 2
            tapGesture.addTarget(self, action: #selector(self.processSampleBuffer(_ :)))
        
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
    /**
     Adds multiple UISwipeGestureRecognizer instances used to control the torch.
     */
    
    internal func setUpTorchGestures() {
        
        // UISwipeGestureRecognizer used to turn the torch on.
        let onSwipeGesture = UISwipeGestureRecognizer()
            onSwipeGesture.direction = .up
            onSwipeGesture.numberOfTouchesRequired = 2
            onSwipeGesture.addTarget(self, action: #selector(self.turnOnTorch))
        
        self.view.addGestureRecognizer(onSwipeGesture)
        
        // UISwipeGestureRecognizer used to turn the torch off.
        let offSwipeGesture = UISwipeGestureRecognizer()
            offSwipeGesture.direction = .down
            offSwipeGesture.numberOfTouchesRequired = 2
            offSwipeGesture.addTarget(self, action: #selector(self.turnOffTorch))
        
        self.view.addGestureRecognizer(offSwipeGesture)
        
    }
    
    
    
    /**
     If available, toggles the torch of the device.
     
     - Parameter on: A boolean parameter that determines whether the torch should be turned on or off.
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
                print("🔦 Torch could not be toggled.")
            }
            
        } else {
            print("🔦 Torch is not available.")
        }
        
    }

}
