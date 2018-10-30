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

    internal func takeTextPicture() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
            
            if authorized {
                
                let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                
            } else {
                
                DispatchQueue.main.async {
                    let alertTitle = "CAMERA ACCESS DENIED"
                    let alertMessage = "Please allow access to your camera in your device settings."
                    let dismissButtonTitle = "OK"
                    let errorAlert = self.createErrorAlert(withAlertTitle: alertTitle,
                                                           alertMessage: alertMessage,
                                                           andDismissButtonTitle: dismissButtonTitle)
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
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
                    print(result.text)
                }
                
            })
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
