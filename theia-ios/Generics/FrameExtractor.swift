//
//  FrameExtractor.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/30/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo



fileprivate struct dispatchQueues {
    static let session = DispatchQueue(label: "sessionQueue")
    static let sampleBuffer = DispatchQueue(label: "sampleBuffer")
}



protocol FrameExtractorDelegate {
    func didCaptureSampleBuffer(buffer: CMSampleBuffer)
}



class FrameExtractor: NSObject {

    // MARK: - Constant Properties
    
    internal let captureSession = AVCaptureSession()
    internal let position = AVCaptureDevice.Position.back
    
    
    
    // MARK: - Variable Properties
    
    var delegate: FrameExtractorDelegate?
    
    
    
    // MARK: - Initializers
    override init() {
        
        super.init()
        
        // Perform video session configurations.
        self.setUpSession()
        
    }
    
    
    
    // MARK: - Functions
    
    internal func checkVideoPermission() {
        
        dispatchQueues.session.suspend()
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { authorized in
            UserDefaults.standard.set(authorized, forKey: "videoPermission")
            dispatchQueues.session.resume()
        })
        
    }
    
    
    
    internal func configureSession() {
        
        let videoAuthorized = UserDefaults.standard.bool(forKey: "videoPermission")
        
        guard
            videoAuthorized,
            let captureDevice = self.selectCaptureDevice(),
            let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
                return
        }
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.medium
        self.captureSession.addInput(videoInput)
 
        let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: dispatchQueues.sampleBuffer)

        self.captureSession.addOutput(videoOutput)
        
    }
    
    
    
    internal func selectCaptureDevice() -> AVCaptureDevice? {
        let backCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        return backCamera.devices.first
    }
    
    
    
    internal func setUpSession() {
        
        self.checkVideoPermission()
        
        // Perform the asynchronous operations on the session thread.
        dispatchQueues.session.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
        
    }
    
}



extension FrameExtractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.delegate?.didCaptureSampleBuffer(buffer: sampleBuffer)
    }
    
}
