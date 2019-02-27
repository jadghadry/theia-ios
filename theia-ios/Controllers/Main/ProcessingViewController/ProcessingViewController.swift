//
//  ProcessingViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/15/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import AVFoundation
import UIKit

class ProcessingViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lblOutput: UILabel?
    @IBOutlet weak var viewBackdrop: UIView?
    
    
    
    // MARK: - Optional Properties
    
    var sampleBufferToProcess: CMSampleBuffer?
    
    
    
    // MARK: - Lazy Variable Properties
    
    lazy var frameExtractor = THFrameExtractor()
    
    
    
    // MARK: - View Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTasks()
    }
    
    
    
    // MARK: - Functions
    
    /**
     Processes the UIImage retrieved using the THFrameExtractorDelegate protocol stub.
     This method should be overridden by inheriting view controllers.
     
     - Parameter image: The UIImage object to be processed.
     */
    
    open func process(_ image: UIImage) {
        
        guard let visionImage = self.visionImageToProcess(fromImage: image) else {
            print("⚠️ Could not retrieve a VisionImage object to process.")
            return
        }
        
        self.process(visionImage)
        
    }
    
    
    
    /**
     Processes the VisionImage input.
     This method should be overridden by inheriting view controllers.
     
     - Parameter visionImage: The VisionImage object to be processed.
     */
    
    open func process(_ visionImage: VisionImage) {
        
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
        
        let previewLayer = AVCaptureVideoPreviewLayer()
            previewLayer.session = self.frameExtractor.captureSession
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.zPosition = -1
        
        self.view.layer.addSublayer(previewLayer)
        
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
        
        // CaptureSession configurations.
        self.setUpUserInterface()
        self.setUpFrameExtractor()
        self.setUpPreviewLayer()
        
        // UIGestureRecognizer configurations.
        self.setUpDismissSwipeGesture()
        self.setUpImageProcessingTapGesture()
        self.setUpTorchGestures()
        
    }
    
    
    
    /**
     Stops all the relevant tasks related to the capture session.
     */
    
    internal func stopTasks() {
        
        let synthesizer = THSpeechSynthesizer.shared
        
        // Stop uttering any current text.
        if synthesizer.isSpeaking() {
            synthesizer.stopSpeaking()
        }
        
        // Stop the frame extractor from running.
        self.frameExtractor.stopRunning()
        
    }

}
