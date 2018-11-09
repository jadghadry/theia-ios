//
//  MainViewController+ImagePicker.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

extension MainViewController {
    
    // MARK: - Functions
    
    internal func takePicture() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
            
            let synthesizer = THSpeechSynthesizer.shared
            
            // Check whether camera access was pauthorized by the user or not.
            guard authorized else {
                synthesizer.speak(text: "Camera access denied. Please allow access before taking any pictures.")
                return
            }
            
            // Check whether there is a camera installed on the device.
            guard UIImagePickerController.isCameraDeviceAvailable(.rear) else {
                synthesizer.speak(text: "There are no cameras installed on your device.")
                return
            }
            
            // If all of the above conditions are met, then we are ready to take a picture for processing.
            DispatchQueue.main.async {
                
                let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: {
                    synthesizer.speak(text: "You can now take a picture.")
                })
                
            }
            
        })
        
    }
    
}



extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if
            let imageTaken = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let fixedImage = imageTaken.fixImageOrientation() {
            
            // Perform OCR operation on the image whose orientation was fixed.
            let textRecognizer = Vision.vision().onDeviceTextRecognizer()
            let capturedImage = VisionImage(image: fixedImage)
            
            textRecognizer.process(capturedImage, completion: { result, error in
                
                if let result = result, error == nil {
                    THSpeechSynthesizer.shared.speak(text: result.text, rate: 0.4)
                    print(result.text)
                }
                
            })
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
