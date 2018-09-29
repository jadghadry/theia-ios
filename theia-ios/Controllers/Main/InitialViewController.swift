//
//  InitialViewController.swift
//  theia-ios
//
//  Created by Jad Ghadry on 9/29/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import Speech
import Lottie

class InitialViewController: JGBaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var lottieVoiceAnimation: LOTAnimationView!
    
    
    
    // MARK: - Constant Properties
    
    let audioEngine = AVAudioEngine()
    let inputNodeBus = 0
    
    
    
    // MARK: - Optional Properties
    
    var command: String?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var speechRecognizer: SFSpeechRecognizer?
    
    
    
    // MARK: - Actions
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        
        // Check whether we need to stop running the audio recording or not.
        if self.audioEngine.isRunning {
            
            // Provide a vibrating feedback.
            AudioServicesPlaySystemSound(UInt32(kSystemSoundID_Vibrate))
            
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.stopSpeechRecognition()
            self.lottieVoiceAnimation.stop()
            
            if let command = self.command {
                self.runCommand(command)
            }
            
            
        } else {
            
            self.startRecording()
            self.lottieVoiceAnimation.play()
            print("Say something, I am listening!")
            
        }
        
    }
    
    
    
    // MARK: - Functions
    
    fileprivate func requestSpeechRecognitionAuthorization(completion: ((Bool) -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            completion?(authStatus == .authorized)
        }
    }
    
    
    
    fileprivate func runCommand(_ command: String) {
        
        let normalizedCommand = command.uppercased()
        
        switch(normalizedCommand) {
            
        case "READ THIS TEXT FOR ME":
            ImagePickerHelper.shared.showUIImagePickerController(withEditPictureSource: .camera, inViewController: self, completion: { image in
                
                DispatchQueue.main.async {
                    
                    // Perform OCR operation.
                    let vision = Vision.vision()
                    let textRecognizer = vision.onDeviceTextRecognizer()
                    let capturedImage = VisionImage(image: image)
                    
                    textRecognizer.process(capturedImage, completion: { result, error in
                        
                        if let result = result, error == nil {
                            print(result.text)
                        }
                        
                    })
                }
                
            })
            
        default:
            return
            
        }
        
        self.command = nil
        
    }
    
    
    
    fileprivate func setUpLottieAnimations() {
        self.lottieVoiceAnimation.loopAnimation = true
    }
    
    
    
    fileprivate func setUpSpeechRecognizer() {
        
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
    
    
    
    fileprivate func startRecognitionTask(forSpeechRecognizer speechRecognizer: SFSpeechRecognizer,
                                          withRecognitionRequest recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            if let error = error {
                
                // Stop the speech recognition tasks.
                self.stopSpeechRecognition()
                
                // Print the error to the console.
                print(error.localizedDescription)
                
            } else if let result = result {
                
                // Update the received command.
                self.command = result.bestTranscription.formattedString
                
            }
            
        })
        
    }
    
    
    
    fileprivate func startRecording() {
        
        // Instantiate the recognitionRequest property.
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check if the speechRecognizer and recognitionRequest properties have been correctly instantiated.
        guard
            let speechRecognizer = self.speechRecognizer,
            let recognitionRequest = self.recognitionRequest else {
                fatalError("One or more properties could not be instantiated.")
        }
        
        // Create and prepare an AVAudioSession for audio recording.
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("An error has occured while setting the audioSession properties.")
        }
        
        // Start the speech recognition by calling the recognitionTask method from the speechRecognizer object.
        self.startRecognitionTask(forSpeechRecognizer: speechRecognizer,
                                  withRecognitionRequest: recognitionRequest)
        
        // Add an audio input to the recognitionRequest.
        let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: self.inputNodeBus)
        self.audioEngine.inputNode.installTap(onBus: self.inputNodeBus, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start the audioEngine.
        do {
            try audioEngine.start()
        } catch {
            print("Could not start the audioEngine property.")
        }
        
    }
    
    
    
    fileprivate func stopSpeechRecognition() {
        
        // Stop the audioEngine.
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: self.inputNodeBus)
        
        // Stop the recognition request.
        self.recognitionRequest = nil
        
        // Stop and cancel the recognitionTask.
        self.recognitionTask = nil
        self.recognitionTask?.cancel()
        
    }
    
}



// MARK: - SFSpeechRecognizerDelegate Extension

extension InitialViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
    
    
}
