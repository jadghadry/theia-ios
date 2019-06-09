//
//  ProcessingViewController+Gestures.swift
//  theia-ios
//
//  Created by Jad Ghadry on 12/9/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import AVFoundation
import UIKit

extension ProcessingViewController {
    
    // MARK: - Functions

    /**
     Adds a UISwipeGestureRecognizer instance used to dismiss the view.
     */
    
    internal func setUpDismissSwipeGesture() {
        
        view.rx
            .swipeGesture(.down)
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    /**
     Adds a UITapGestureRecognizer instance used to process a VisionImage input.
     */
    
    internal func setUpImageProcessingTapGesture() {
        
        view.rx
            .tapGesture(configuration: { gesture, _ in
                gesture.numberOfTapsRequired = 2
            })
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                
                THSpeechSynthesizer.shared.toggleSpeaking({ [weak self] isSpeaking in
                    
                    if isSpeaking {
                        return
                    }
                    
                    guard let image = self?.imageFromSampleBuffer() else {
                        print("⚠️ Could not retrieve a UIImage object to process.")
                        return
                    }
                    
                    self?.process(image)
                    
                })
                
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    /**
     Adds multiple UISwipeGestureRecognizer instances used to control the torch.
     */
    
    internal func setUpTorchGestures() {
        
        view.rx
            .swipeGesture([.up, .down], configuration: { gesture, _ in
                gesture.numberOfTouchesRequired = 2
            })
            .when(.recognized)
            .subscribe(onNext: { [weak self] gesture in
                
                if gesture.direction == .up {
                    self?.toggleTorch(true)
                } else if gesture.direction == .down {
                    self?.toggleTorch(false)
                }
                
            })
            .disposed(by: disposeBag)
        
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
