//
//  MainViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 9/29/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import Speech
import Lottie

class MainViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lottieVoiceAnimation: LOTAnimationView!
    
    
    
    // MARK: - Constant Properties
    
    let audioEngine = AVAudioEngine()
    let synthesizer = AVSpeechSynthesizer()
    
    
    
    // MARK: - Optional Properties
    
    var command: String?
    var captureSession: AVCaptureSession?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var speechRecognizer: SFSpeechRecognizer?

    
    
    // MARK: - Actions
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        
        // Check wether the synthesizer is speaking.
        if self.synthesizer.isSpeaking {
            
            // Provide a vibrating feedback.
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            
            // Stop the speech
            self.synthesizer.stopSpeaking(at: .immediate)
            
            // Exit the function scope
            return
        }
        
        // Check audio engine status
        if self.audioEngine.isRunning {
            
            // If the audio engine was running, then we need to stop listenting for additional audio.
            self.stopSpeechRecognition()
            self.lottieVoiceAnimation.stop()
            self.runCommand(self.command)
            
        } else {
            
            // If the audio engine was not running, then we need to start listenting for audio input.
            self.startRecording()
            self.lottieVoiceAnimation.play()
            print("Say something, I am listening!")
            
        }
        
    }
    
    
    
    // MARK: - Functions
    
    internal func requestSpeechRecognitionAuthorization(completion: ((Bool) -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            completion?(authStatus == .authorized)
        }
    }
    
    
    
    internal func setUpCaptureSession() {
        
        // Create and prepare an AVCaptureSession for audio playback and recording.
        self.captureSession = AVCaptureSession()
        
        // Check if the captureSession was correctly instantiated
        guard
            let captureSession = self.captureSession else {
            fatalError("Could not instantiate the capture session.")
        }
        
        // Instantiate the relevant audio inputs.
        guard
            let audioDevice = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
                fatalError("Could not add capture device to the capture session.")
        }
        
        // Instantiate the relevant audio outputs.
        let audioOutput = AVCaptureAudioDataOutput()
            audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        // Add audio input, audio output and start the capture session.
        captureSession.addInput(audioInput)
        captureSession.addOutput(audioOutput)
        captureSession.startRunning()
        
    }
    
    
    
    internal func setUpLottieAnimations() {
        self.lottieVoiceAnimation.loopAnimation = true
    }
    
    
    
    internal func setUpSpeechRecognizer() {
        
        // Define the language that will be interpreted by the speech recognizer.
        let englishLocale = Locale(identifier: "en-US")
        
        // Configure the speech recognizer.
        self.speechRecognizer = SFSpeechRecognizer(locale: englishLocale)
        self.speechRecognizer?.delegate = self
        
    }
    
    
    
    override func setUpViewController() {
        
        super.setUpViewController()
        
        // Call relevant view controller configurations.
        self.setUpLottieAnimations()
        self.setUpSpeechRecognizer()
        
        // Request speech input authorization.
        self.requestSpeechRecognitionAuthorization()
        
    }
    
    
    
    // MARK: - Functions
    
    /**
     Speaks a text using the AVSpeechSynthesizer object.
     
     - Parameter text: The text to be spoken by the utterance object.
     - Parameter language: the language and locale from which a voice object will be initialized.
     - Parameter rate: The rate at which the utterance will be spoken.
     */
    
    internal func speak(text: String, language: String = "en-GB", rate: Float = 0.5) {
        
        // Determine the utterance to be spoken
        let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            utterance.rate = rate
        
        self.synthesizer.speak(utterance)
        
    }
    
    
    
    internal func startRecognitionTask(forSpeechRecognizer speechRecognizer: SFSpeechRecognizer,
                                       withRecognitionRequest recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { [unowned self] result, error in
            
            if let _ = error {
                
                // Stop the speech recognition tasks.
                self.stopSpeechRecognition()
                
            } else if let result = result {
                
                // Update the received command.
                self.command = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
                
            }
            
        })
        
    }
    
    
    
    internal func startRecording() {
        
        // Instantiate the recognitionRequest property.
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check if the speechRecognizer and recognitionRequest properties have been correctly instantiated.
        guard
            let speechRecognizer = self.speechRecognizer,
            let recognitionRequest = self.recognitionRequest else {
                fatalError("One or more properties could not be instantiated.")
        }
        
        // Set up the capture session.
        self.setUpCaptureSession()
        
        // Start the speech recognition by calling the recognitionTask method from the speechRecognizer object.
        self.startRecognitionTask(forSpeechRecognizer: speechRecognizer,
                                  withRecognitionRequest: recognitionRequest)
        
        // Add an audio input to the recognitionRequest property.
        let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: 0)
        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start the audioEngine.
        do {
            try audioEngine.start()
        } catch {
            print("Could not start the audioEngine property.")
        }
        
    }
    
    
    
    internal func stopSpeechRecognition() {
        
        // Stop the capture session.
        self.captureSession?.stopRunning()
        self.captureSession = nil
        
        // Stop the audio engine.
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        
        // End and deallocate the recognition request.
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        
        // Cancel and deallocate the recognition task.
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        
    }
    
}



// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate Extension

extension MainViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
}



// MARK: - SFSpeechRecognizerDelegate Extension

extension MainViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
    
    
}
