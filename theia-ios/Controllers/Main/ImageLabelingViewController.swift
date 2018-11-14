//
//  ImageLabelingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/13/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

class ImageLabelingViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lblDescription: UILabel!
    
    
    
    // MARK: - Variable Properties
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
    
    // MARK: - Optional Properties
    
    var frameExtractor: THFrameExtractor?
    var labelDetector: VisionLabelDetector?
    
    
    
    // MARK: - View Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.frameExtractor?.captureSession.stopRunning()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func didTapView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Functions
    
    /**
     Configures the THFrameExtractor instance.
     */
    
    internal func setUpFrameExtractor() {
        self.frameExtractor = THFrameExtractor()
        self.frameExtractor?.delegate = self
    }
    
    
    
    /**
     Configures the MLKit label detector with the required models and confidence threshold.
     */
    
    internal func setUpLabelDetector() {
        
        let options = VisionLabelDetectorOptions(confidenceThreshold: 0.85)
        let vision = Vision.vision()
        
        self.labelDetector = vision.labelDetector(options: options)
        
    }
    
    
    
    /**
     Configures the preview layer with the frame extractor session.
     */
    
    internal func setUpPreviewLayer() {
        
        self.previewLayer.session = self.frameExtractor?.captureSession
        self.previewLayer.frame = UIScreen.main.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.zPosition = -1

        self.view.layer.addSublayer(self.previewLayer)
        
    }
    
    
    
    /**
     Configures user interface elements upon loading the view into memory.
     */
    
    internal func setUpUserInterface() {
        self.updateStatusBarStyle(to: .lightContent)
    }
    
    
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        // Call relevant view controller configurations.
        self.setUpUserInterface()
        self.setUpFrameExtractor()
        self.setUpPreviewLayer()
        self.setUpLabelDetector()
        
    }

}




// MARK: - THFrameExtractorDelegate Extension

extension ImageLabelingViewController: THFrameExtractorDelegate {
    
    func didCaptureSampleBuffer(_ buffer: CMSampleBuffer) {
        
        // Perform image processing on the received frame buffers.
        
        let imageOrientation = THUtilities.imageOrientation()
        let visionOrientation = THUtilities.visionImageOrientation(from: imageOrientation)
        
        let customMetadata = VisionImageMetadata()
            customMetadata.orientation = visionOrientation
        
        let image = VisionImage(buffer: buffer)
            image.metadata = customMetadata
        
        self.labelDetector?.detect(in: image, completion: { [unowned self] (results, error) in

            // Check whether there was an error in labeling the image.
            if let error = error {
                THSpeechSynthesizer.shared.speak(text: error.localizedDescription)
                return
            }
            
            // Get the detected object with the highest confidence level.
            if let results = results {
                
                let highestConfidenceObject = results.max(by: {
                    $0.label > $1.label
                })
                
                DispatchQueue.main.async {
                    self.lblDescription.text = highestConfidenceObject?.label ?? "Nothing detected"
                }
                
            }

        })
        
    }
    
}
