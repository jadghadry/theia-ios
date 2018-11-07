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
        self.synthesizer = AVSpeechSynthesizer()
    }
    
    
    
    // MARK: - Functions
    
    /**
     Speaks a text using the AVSpeechSynthesizer object.
     
     - Parameter text: The text to be spoken by the utterance object.
     - Parameter language: The language and locale from which a voice object will be initialized.
     - Parameter rate: The rate at which the utterance will be spoken.
     */
    
    open func speak(text: String, language: String = "en-GB", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        
        // Define the utterance to be spoken.
        let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(identifier: language)
            utterance.rate = rate
        
        self.synthesizer.speak(utterance)
        
    }
    
}
