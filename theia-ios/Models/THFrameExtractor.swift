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



fileprivate struct THFrameExtractorQueue {
    static let session = DispatchQueue(label: "sessionQueue")
    static let sampleBuffer = DispatchQueue(label: "sampleBuffer")
}



@objc protocol THFrameExtractorDelegate {
    func didCaptureSampleBuffer(_ sampleBuffer: CMSampleBuffer)
}



class THFrameExtractor: NSObject {

    // MARK: - Constant Properties
    
    let captureSession = AVCaptureSession()
    
    
    
    // MARK: - Variable Properties
    
    weak var delegate: THFrameExtractorDelegate?
    
    
    
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
        
        let videoAuthorized = UserDefaults.standard.bool(forKey: THKey.videoPermission)
        
        // Input Configuration.
        guard
            videoAuthorized,
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
                return
        }
        
        self.captureSession.addInput(videoInput)
 
        // Output Configuration.
        let bufferPixelFormatTypeKey = kCVPixelBufferPixelFormatTypeKey as String
        let videoSettings = [bufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
        
        let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = videoSettings
            videoOutput.setSampleBufferDelegate(self, queue: THFrameExtractorQueue.sampleBuffer)

        self.captureSession.addOutput(videoOutput)
        
    }
    
    
    
    /**
     Requests video recording access in order to capture the relevant image frames.
     This method is responsible of suspending the session queue and only resumes it after receiving the asynchronous authorization status.
     */
    
    internal func requestVideoPermission() {
        
        THFrameExtractorQueue.session.suspend()
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
            UserDefaults.standard.set(authorized, forKey: THKey.videoPermission)
            THFrameExtractorQueue.session.resume()
        })
        
    }
    
    
    
    /**
     Sets up the AVCaptureSession and tells the receiver to run after
     */
    
    internal func setUpSession() {
        
        self.requestVideoPermission()
        
        // Perform the asynchronous operations on the session thread.
        THFrameExtractorQueue.session.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
        
    }
    
    
    
    /**
     Tells the AVCaptureSession object to stop running.
     */
    
    func stopRunning() {
        self.captureSession.stopRunning()
    }
    
}



// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension THFrameExtractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.didCaptureSampleBuffer(sampleBuffer)
        }
        
    }
    
}
