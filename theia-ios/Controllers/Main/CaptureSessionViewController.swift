//
//  CaptureSessionViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/15/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureSessionViewController: JGBaseViewController {

    // MARK: - Variable Properties
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
    
    // MARK: - Optional Properties
    
    var processedText: String?
    
    
    
    // MARK: - Lazy Variable Properties
    
    lazy var frameExtractor = THFrameExtractor()
    
    
    
    // MARK: - View Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.frameExtractor.stopRunning()
    }
    
    
    
    // MARK: - Selectors
    
    @objc func didSwipeView(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // WARNING: '_BeginSpeaking: couldn't begin playback'.
        if synthesizer.isSpeaking() {
            synthesizer.stopSpeaking()
            return
        }
        
        guard let processedText = self.processedText else {
            synthesizer.speak(text: "An error has occurred while processing the image.")
            return
        }
        
        synthesizer.speak(text: processedText)
        
    }
    
    
    
    // MARK: - Functions
    
    /**
     Processes the VisionImage retrieved from the THFrameExtractorDelegate protocol stub.
     
     - Parameter image: The VisionImage object to be processed.
     */
    
    open func processVisionImage(_ image: VisionImage) {
        
    }
    
    
    
    /**
     Configures the THFrameExtractor instance.
     */
    
    internal func setUpFrameExtractor() {
        self.frameExtractor.delegate = self
    }
    
    
    
    /**
     Configures the preview layer with the frame extractor session.
     */
    
    internal func setUpPreviewLayer() {
        
        self.previewLayer.session = self.frameExtractor.captureSession
        self.previewLayer.frame = UIScreen.main.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.zPosition = -1
        
        self.view.layer.addSublayer(self.previewLayer)
        
    }
    
    
    
    /**
     Adds a UISwipeGestureRecognizer to the view.
     */
    
    internal func setUpSwipeGesture() {
        
        let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .down
            swipeGesture.addTarget(self, action: #selector(self.didSwipeView(_:)))
        
        self.view.addGestureRecognizer(swipeGesture)
        
    }
    
    
    
    /**
     Adds a UITapGestureRecognizer to the view.
     */
    
    internal func setUpTapGesture() {
        
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 2
            tapGesture.addTarget(self, action: #selector(self.didTapView(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
    /**
     Configures user interface elements upon loading the view into memory.
     */
    
    internal func setUpUserInterface() {
        self.updateStatusBarStyle(to: .lightContent)
    }
    
    
    
    /**
     Call relevant view controller configurations.
     */
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        self.setUpUserInterface()
        self.setUpFrameExtractor()
        self.setUpPreviewLayer()
        self.setUpSwipeGesture()
        self.setUpTapGesture()
        
    }

}



// MARK: - THFrameExtractorDelegate Extension

extension CaptureSessionViewController: THFrameExtractorDelegate {
    
    func didCaptureSampleBuffer(_ buffer: CMSampleBuffer) {
        
        // Modify the orientation of the retrieved buffer before sending it to processing.
        let imageOrientation = THUtilities.imageOrientation()
        let visionOrientation = THUtilities.visionImageOrientation(from: imageOrientation)
        
        let customMetadata = VisionImageMetadata()
            customMetadata.orientation = visionOrientation
        
        let image = VisionImage(buffer: buffer)
            image.metadata = customMetadata
        
        // Process the Vision Image object.
        self.processVisionImage(image)
    }
    
}
