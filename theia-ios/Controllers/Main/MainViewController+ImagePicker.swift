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
            
            if authorized {
                
                let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                
            } else {
                
                self.speak(text: "Camera access denied, please allow access before taking any pictures")
                    
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
            let vision = Vision.vision()
            let textRecognizer = vision.onDeviceTextRecognizer()
            let capturedImage = VisionImage(image: fixedImage)
            
            textRecognizer.process(capturedImage, completion: { result, error in
                
                if let result = result, error == nil {
                    self.speak(text: result.text)
                }
                
            })
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
