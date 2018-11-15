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
    func didCaptureSampleBuffer(_ buffer: CMSampleBuffer)
}



class THFrameExtractor: NSObject {

    // MARK: - Constant Properties
    
    let captureSession = AVCaptureSession()
    let context = CIContext()
    
    
    
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
     Returns an optional UIImage from a CMSampleBuffer frame.
     
     - Parameter sampleBuffer: The CMSampleBuffer to be converted.
     */
    
    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        
        // Transform the CMSampleBuffer to a CVImageBuffer.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        // Create a CIImage from the imageBuffer object.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Get a CGImage from the CIContext.
        guard let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
    
    
    /**
     Requests video recording access in order to capture the relevant image frames.
     This method is responsible of suspending the session queue and only resumes it after receiving the asynchronous authorization status.
     */
    
    internal func requestVideoPermission() {
        
        THFrameExtractorQueue.session.suspend()
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
            UserDefaults.standard.set(authorized, forKey: "videoPermission")
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
        self.delegate?.didCaptureSampleBuffer(sampleBuffer)
    }
    
}
