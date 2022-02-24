//
//  DtmfPlayer.swift
//  PIL
//
//  Created by Chris Kontos on 27/04/2021.
//

import Foundation
import AVFoundation

class DtmfPlayer {
    
    let pil: PIL
    
    private var dtmfTones = [String: AVAudioPlayer]()
    
    init(pil: PIL){
        self.pil = pil
        setupDtmfTones()
    }
    
    private func setupDtmfTones() {
        DispatchQueue.global(qos: .userInteractive).async {
            var dtmfTones = [String: AVAudioPlayer]()
            for digit in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "#", "*"] {
                let soundFileName = "dtmf-\(digit)"
                
                guard let soundFileURL = Bundle(for: type(of: self)).url(forResource: soundFileName,  withExtension:"aif") else {
                    self.pil.writeLog("Invalid url for sound file.")
                    return
                }
                                
                do {
                    let tone = try AVAudioPlayer(contentsOf: soundFileURL)
                    tone.prepareToPlay()
                    dtmfTones[digit] = tone
                } catch let error {
                    self.pil.writeLog("Couldn't load sound: \(error)")
                }
            }
            self.dtmfTones = dtmfTones
        }
    }
    
    func playTone(_ character: String) {
        guard let tone = dtmfTones[character] else {return}
        tone.currentTime = 0
        tone.play()
    }
}
