//
//  THFrameExtractor.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo



fileprivate struct dispatchQueue {
    static let session = DispatchQueue(label: "sessionQueue")
    static let sampleBuffer = DispatchQueue(label: "sampleBuffer")
}



protocol THFrameExtractorDelegate {
    func didCaptureSampleBuffer(_ buffer: CMSampleBuffer)
}



class THFrameExtractor: NSObject {

    // MARK: - Constant Properties
    
    internal let captureSession = AVCaptureSession()
    
    
    
    // MARK: - Variable Properties
    
    var delegate: THFrameExtractorDelegate?
    
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        self.setUpSession()
    }
    
    
    
    // MARK: - Functions
    
    /**
     Configures the AVCaptureSession by modifying any required settings and adding the corresponding inputs and outputs.
     The default capture device used for the frame extraction process is the .builtInWideAngleCamera.
     */
    
    internal func configureSession() {
        
        let videoAuthorized = UserDefaults.standard.bool(forKey: "videoPermission")
        
        guard
            videoAuthorized,
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
                return
        }
        
        self.captureSession.addInput(videoInput)
 
        let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: dispatchQueue.sampleBuffer)

        self.captureSession.addOutput(videoOutput)
        
    }
    
    
    
    /**
     Requests video recording access in order to capture the relevant image frames.
     This method is responsible of suspending the session queue and only resumes it after receiving the authorization status.
     */
    
    internal func requestVideoPermission() {
        
        dispatchQueue.session.suspend()
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
            UserDefaults.standard.set(authorized, forKey: "videoPermission")
            dispatchQueue.session.resume()
        })
        
    }
    
    
    
    /**
     Sets up the AVCaptureSession and tells the receiver to run after
     */
    
    internal func setUpSession() {
        
        self.requestVideoPermission()
        
        // Perform the asynchronous operations on the session thread.
        dispatchQueue.session.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
        
    }
    
}



// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension THFrameExtractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.delegate?.didCaptureSampleBuffer(sampleBuffer)
        }
    }
    
}
