//
//  DialerViewController.swift
//  PhoneLibExample
//
//  Created by Jeremy Norman on 12/02/2021.
//

import Foundation
import UIKit
import iOSPhoneLib
import Contacts

class DialerViewController: UIViewController {
    
    @IBOutlet weak var numberPreview: UITextField!
        
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPreview.text = ""
        
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            
        }
        
        if let environmentDestination = ProcessInfo.processInfo.environment["pil.default.destination"] {
            numberPreview.text = environmentDestination
        }
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        guard let number = numberPreview.text,
              let pil = PIL.shared else { return }
        
        pil.preferences = Preferences(
            useApplicationRingtone: pil.preferences.useApplicationRingtone,
            includesCallsInRecents: pil.preferences.includesCallsInRecents,
            supplementaryContacts: [SupplementaryContact(number: number, name: "Supplementary Contact")]
        )

        
        MicPermissionHelper.requestMicrophonePermission { startCalling in
            if startCalling {
                pil.call(number: number)
            }
        }
    }
    
    @IBAction func deleteButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        
        if currentNumberPreview.isEmpty { return }
        
        numberPreview.text = String(currentNumberPreview.prefix(currentNumberPreview.count - 1))
    }
    
    @IBAction func keypadButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        let buttonNumber = sender.currentTitle ?? ""
        
        numberPreview.text = currentNumberPreview + buttonNumber
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
}
