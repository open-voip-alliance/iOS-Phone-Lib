//
//  InCallDialpadViewController.swift
//  PhoneLibExample
//
//  Created by Chris Kontos on 08/04/2021.
//

import Foundation
import UIKit
import iOS_Phone_Lib
import Contacts

class InCallDialpadViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var numberPreview: UITextField!
        
    private let defaults = UserDefaults.standard
    
    let pil = PIL.shared!

    // MARK: Life circle
    override func viewDidLoad() {
        super.viewDidLoad()

        numberPreview.text = ""
    }
    
    // MARK: UI
    @IBAction func hideButtonWasPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func keypadButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        let buttonNumber = sender.currentTitle ?? ""
        
        pil.actions.sendDtmf(buttonNumber, playToneLocally: self.defaults.bool(forKey: "play_dtmf_tones"))
        
        numberPreview.text = currentNumberPreview + buttonNumber
    }
}

