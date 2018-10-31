//
//  MainViewController+SpeechSynthesizer.swift
//  theia-ios
//
//  Created by Jad Ghadry on 10/31/18.
//  Copyright © 2018 Jad Ghadry. All rights reserved.
//

import UIKit
import AVFoundation

extension MainViewController {

    // Functions
    
    /**
     Speaks a text using the AVSpeechSynthesizer object.
     
     - Parameter text: The text to be spoken by the utterance object.
     - Parameter language: the language and locale from which a voice object will be initialized.
     - Parameter rate: The rate at which the utterance will be spoken.
     */
    
    internal func speak(text: String, language: String = "en-GB", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        
        // Determine the utterance to be spoken
        let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(identifier: language)
            utterance.rate = rate
        
        self.synthesizer.speak(utterance)
        
    }

}
