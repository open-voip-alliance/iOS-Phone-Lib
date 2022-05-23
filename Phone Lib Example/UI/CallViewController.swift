//
//  CallViewController.swift
//  PhoneLibExample
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib
import UIKit

class CallViewController: UIViewController, PILEventDelegate {
    
    @IBOutlet weak var callTitle: UILabel!
    @IBOutlet weak var callSubtitle: UILabel!
    @IBOutlet weak var callDuration: UILabel!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var inactiveCallStatus: UILabel!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    @IBOutlet weak var earpieceButton: UIButton!
    @IBOutlet weak var bluetoothMultipleDeviceButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var bluetoothSingleDeviceButton: UIButton!
    
    let pil = PIL.shared!
    
    private var event: Event?
    private var callSessionState: CallSessionState?
    
    override func viewWillAppear(_ animated: Bool) {
        render()
        pil.events.listen(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        pil.events.stopListening(delegate: self)
    }
    
    func onEvent(event: Event) {
        self.event = event
        
        switch event {
        case .callEnded(_):
            self.dismiss(animated: true)
        case .incomingCallReceived(let state),
             .outgoingCallStarted(let state),
             .callDurationUpdated(let state),
             .callConnected(let state),
             .callStateUpdated(let state),
             .attendedTransferAborted(let state),
             .attendedTransferEnded(let state),
             .attendedTransferConnected(let state),
             .attendedTransferStarted(let state),
             .audioStateUpdated(let state):
            self.callSessionState = state
            fallthrough
        default:
            self.render()
        }
    }
    
    private func render() {
        guard let call = callSessionState?.activeCall ?? pil.calls.activeCall else {
            self.dismiss(animated: true)
            return
        }
        
        DispatchQueue.main.async {
            self.renderCallInfo(call: call)
            self.renderCallButtons(call: call)
        }
        
        renderForEventStatus(call: call)
    }
    
    private func renderCallInfo(call: Call) {
        self.callTitle.text = "\(call.remotePartyHeading) - \(call.remotePartySubheading)"
        self.callSubtitle.text = String(describing: call.direction)
        self.callDuration.text = call.prettyDuration
        self.callStatus.text = String(describing: call.state)
    }
    
    private func renderCallButtons(call: Call) {
        let audioState: AudioState
        let isMicrophoneMuted: Bool
        if let callSessionState = self.callSessionState {
            audioState = callSessionState.audioState
            isMicrophoneMuted = audioState.isMicrophoneMuted
        } else {
            audioState = pil.audio.state
            isMicrophoneMuted = pil.audio.isMicrophoneMuted
        }
        
        if isMicrophoneMuted {
            muteButton.isSelected = true
            muteButton.setTitle("UNMUTE", for: .normal)
        } else {
            muteButton.isSelected = false
            muteButton.setTitle("MUTE", for: .normal)
        }
        
        if call.isOnHold {
            holdButton.isSelected = true
            holdButton.setTitle("UNHOLD", for: .normal)
        } else {
            holdButton.isSelected = false
            holdButton.setTitle("HOLD", for: .normal)
        }
        
        bluetoothMultipleDeviceButton.isEnabled = audioState.availableRoutes.contains(.bluetooth)
        earpieceButton.isEnabled = audioState.availableRoutes.contains(.phone)
        speakerButton.isEnabled = audioState.availableRoutes.contains(.speaker)
        bluetoothSingleDeviceButton.isEnabled = audioState.availableRoutes.contains(.bluetooth)
        
        speakerButton.isSelected = audioState.currentRoute == .speaker
        bluetoothMultipleDeviceButton.isSelected = audioState.currentRoute == .bluetooth
        earpieceButton.isSelected = audioState.currentRoute == .phone
        bluetoothSingleDeviceButton.isSelected = audioState.currentRoute == .bluetooth
        
        bluetoothMultipleDeviceButton.setTitle(audioState.bluetoothDeviceName ?? "BLUETOOTH", for: .normal)
        bluetoothSingleDeviceButton.setTitle(audioState.bluetoothDeviceName ?? "BLUETOOTH", for: .normal)
        
        if callSessionState?.inactiveCall != nil {
            transferButton.setTitle("MERGE", for: .normal)
        } else {
            transferButton.setTitle("TRANSFER", for: .normal)
        }
    }
    
    private func renderForEventStatus(call: Call) {
        switch event {
        case .incomingCallReceived:
            showEventStatus(message: "Incoming Call Received: In call with \(call.displayName)")
        case .outgoingCallStarted:
            showEventStatus(message: "Outgoing Call Started: In call with  \(call.displayName)")
        case .callConnected:
            showEventStatus(message: "Call Connected: In call with \(call.displayName)")
        case .callEnded:
            self.dismiss(animated: true, completion: nil)
        case .attendedTransferStarted:
            showEventStatus(message: "Call Transfer Started: Calling \(call.displayName)")
        case .attendedTransferAborted:
            showEventStatus(message: "Call Transfer Aborted: In call with \(call.displayName)")
        case .attendedTransferConnected:
            showEventStatus(message: "Call Transfer Connected: In call with  \(call.displayName)")
        case .attendedTransferEnded:
            if let inactiveCall = callSessionState?.inactiveCall {
                showEventStatus(message: "Call Transfer Ended: Merged calls with \(call.displayName) and \(inactiveCall.displayName)")
            }
        case .incomingCallSetupFailed:
            showEventStatus(message: "Incoming Call Setup Failed")
        case .outgoingCallSetupFailed:
            showEventStatus(message: "Outgoing Call Setup Failed")
        case .none, .callStateUpdated, .audioStateUpdated, .callDurationUpdated:
            return
        }
    }
    
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        pil.actions.end()
    }
    
    @IBAction func bluetoothButtonWasPressed(_ sender: Any) {
        pil.audio.launchAudioRoutePicker()
    }
    
    @IBAction func bluetoothSingleButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(.bluetooth)
    }

    @IBAction func earpieceButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(.phone)
    }

    @IBAction func speakerButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(.speaker)
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
        if pil.calls.inactiveCall == nil {
            self.pil.actions.hold()
            promptForTransferNumber { number in
                self.pil.actions.beginAttendedTransfer(number: number)
            }
        } else {
            pil.actions.completeAttendedTransfer()
        }
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
        pil.actions.toggleHold()
        render()
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        pil.audio.toggleMute()
        render()
    }
    
    @IBAction func dialpadButtonWasPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowInCallDialpadViewController", sender: self)
    }
    
    private func promptForTransferNumber(callback: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Call Transfer", message: "Enter the number to transfer to", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "080012341234"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Transfer", style: .default) { _ in
            callback(alertController.textFields![0].text!)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func showEventStatus(message: String) {
        DispatchQueue.main.async {
            self.inactiveCallStatus.text = message
            let screenWidth = UIScreen.main.bounds.width
            self.inactiveCallStatus.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        }
    }
}
