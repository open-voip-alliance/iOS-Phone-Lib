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
        //wip fast setup
        numberPreview.text = "0630821207"
        self.defaults.set("497920083", forKey: "username")
        self.defaults.set("pxNnxaxb56AK8hr", forKey: "password")
        self.defaults.set(UrlsConfiguration.shared.encryptedSipDomain(), forKey: "domain")
        self.defaults.set("5060", forKey: "port")
        
        self.defaults.set("chris2@vialerapp.com", forKey: "voipgrid_username")
        self.defaults.set("password123", forKey: "voipgrid_password")
        //wip
        
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            
        }
        
        if let environmentDestination = ProcessInfo.processInfo.environment["pil.default.destination"] {
            numberPreview.text = environmentDestination
        }
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        guard let number = numberPreview.text,
              let pil = PIL.shared else { return }
        
        pil.start { _ in
                MicPermissionHelper.requestMicrophonePermission { startCalling in
                    if startCalling {
                        pil.call(number: number)
                    }
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
