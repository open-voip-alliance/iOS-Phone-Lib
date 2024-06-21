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

    func requestNotificationPermission()  {
        let center = UNUserNotificationCenter.current()

        do {
          try center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
              // Notification permission granted
              print("Notifications permission granted")
            } else {
              // Permission denied
              print("Notifications permission denied")
            }
            if let error = error {
              print("Error requesting notification permission: \(error.localizedDescription)")
            }
          }
        } catch {
          // Handle error
          print("Error requesting notification permission: \(error.localizedDescription)")
        }
    }
    
    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        requestNotificationPermission()
        
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
