//
//  THESpeechSynthesizer.swift
//  theia-ios
//
//  Created by Jad Ghadry on 11/3/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import AVFoundation
import Foundation

class THSpeechSynthesizer {
    
    // MARK: - Singleton Object
    
    static let shared = THSpeechSynthesizer()
    
    
    
    // MARK: - Constant Properties
    
    let synthesizer: AVSpeechSynthesizer
    
    
    
    // MARK: - Private Initializer
    
    private init() {
        synthesizer = AVSpeechSynthesizer()
    }
    
    
    
    // MARK: - Functions
    
    /**
     Speaks a text using the AVSpeechSynthesizer object.
     
     - Parameter text: The text to be spoken by the utterance object.
     - Parameter language: The language and locale from which a voice object will be initialized.
     - Parameter rate: The rate at which the utterance will be spoken.
     */
    
    open func speak(text: String, language: String = "en-US", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        
        // Instantiate the utterance to be spoken.
        let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            utterance.rate = rate
        
        synthesizer.speak(utterance)
        
    }
    
    
    
    /**
     Toggles the speaking state of the synthesizer.
     
     - Parameter handler: The callback triggered with the synthesizer.isSpeaking boolean parameter.
     */
    
    open func toggleSpeaking(_ handler: ((Bool) -> Void)? = nil) {
        
        if synthesizer.isSpeaking {
            
            handler?(true)
            synthesizer.stopSpeaking(at: .immediate)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
        } else {
            
            handler?(false)
            
        }
        
    }
    
}
