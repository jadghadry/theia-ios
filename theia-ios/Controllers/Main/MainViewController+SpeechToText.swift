//
//  MainViewController+SpeechToText.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/31/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import Speech

extension MainViewController {

    // MARK: - Functions
    
    /**
     Asks the user to grant your app the permission to perform speech recognition.
     */
    
    internal func requestSpeechRecognitionAuthorization(completion: ((Bool) -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            completion?(authStatus == .authorized)
        }
    }
    
    
    
    /**
     Installs an audio tap on the bus to record, monitor, and observe thexoutput of the node.
     
     Only one tap may be installed on any bus. Taps may be safely installed and removed while the engine is running.
     */
    internal func setUpAudioInputTap() {
        
        let format = self.audioEngine.inputNode.outputFormat(forBus: 0)
        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 512, format: format, block: { buffer, _ in
            self.recognitionRequest?.append(buffer)
        })
        
    }
    
    
    
    /**
     Sets the category, mode, and desired options on the shared AVAudioSession, then activates it for audio multi-routing.
    */
    
    internal func setUpAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.multiRoute, mode: .default, options: [.defaultToSpeaker, .duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("An error has occured while setting the audioSession properties.")
        }
        
    }
    
    
    
    /**
     Initializes the SFSpeechRecognizer object using an english locale.
     */
    
    internal func setUpSpeechRecognizer() {
        
        let englishLocale = Locale(identifier: "en-US")
        
        self.speechRecognizer = SFSpeechRecognizer(locale: englishLocale)
        self.speechRecognizer?.delegate = self
        
    }
    
    
    
    /**
     Recognizes speech from the audio source associated with the specified request, using the specified completion handler to handle the results.
     */
    
    internal func startRecognitionTask() {
        
        guard
            let speechRecognizer = self.speechRecognizer,
            let recognitionRequest = self.recognitionRequest else {
                fatalError("One or more properties could not be instantiated.")
        }
        
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { [unowned self] result, error in
            
            if error != nil {
                
                // Stop the audio engine and recognition task.
                self.stopSpeechRecognition()
                
            } else if let result = result {
                
                let bestTranscriptionString = result.bestTranscription.formattedString
                
                self.command = bestTranscriptionString
                print(bestTranscriptionString)
                
            }
            
        })
        
    }
    
    
    
    /**
     Starts the speech recognition process.
     
     This function is responsible of instantiating the required speech recognition properties.
     It is also responsible of setting up audio session, the speech recognition task and the audio input tap on the audio engine.
     */
    
    internal func startSpeechRecognition() {
        
        // Instantiate the recognitionRequest property.
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Set up the audio session.
        self.setUpAudioSession()
        
        // Start the speech recognition task.
        self.startRecognitionTask()
        
        // Add an audio input to the recognitionRequest property.
        self.setUpAudioInputTap()
        
        // Start the audioEngine.
        do {
            try self.audioEngine.start()
        } catch {
            print("Could not start the audioEngine property.")
        }
        
    }
    
    
    
    /**
     Stops the speech recognition process.
     
     This function is responsible of deallocating the speech recognition properties used in the startSpeechRecognition() method.
     It is also responsible of stopping audio session, ending the speech recognition request and cancelling the speech recognition task.
     */
    
    internal func stopSpeechRecognition() {
        
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



// MARK: - SFSpeechRecognizerDelegate Extension

extension MainViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
    
    
}

