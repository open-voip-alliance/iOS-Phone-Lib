//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import CallKit
import iOSVoIPLib

public class CallActions {
    
    private let controller: CXCallController
    private let pil: PIL
    private let voipLib: VoIPLib
    
    init(controller: CXCallController, pil: PIL, voipLib: VoIPLib) {
        self.controller = controller
        self.pil = pil
        self.voipLib = voipLib
    }

    public func hold() {
        performCallAction { uuid -> CXCallAction in
            CXSetHeldCallAction(call: uuid, onHold: true)
        }
    }
    
    public func unhold() {
        performCallAction { uuid -> CXCallAction in
            CXSetHeldCallAction(call: uuid, onHold: false)
        }
    }
    
    public func toggleHold() {
        let isOnHold: Bool = pil.calls.activeCall!.isOnHold
        
        if isOnHold {
            unhold()
        } else {
            hold()
        }
    }
    
    public func answer() {
        performCallAction { uuid -> CXCallAction in
            CXAnswerCallAction(call: uuid)
        }
    }
    
    public func decline() {
        performCallAction { uuid -> CXCallAction in
            CXEndCallAction(call: uuid)
        }
    }
    
    public func end() {
        if pil.calls.isInTransfer {
            if let call = pil.calls.activeVoipLibCall {
                pil.voipLib.actions(call: call).end()
            }
            return
        }

        performCallAction { uuid -> CXCallAction in
            CXEndCallAction(call: uuid)
        }
    }
    
    func mute() {
        performCallAction { uuid -> CXCallAction in
            CXSetMutedCallAction(call: uuid, muted: true)
        }
    }
    
    func unmute() {
        performCallAction { uuid -> CXCallAction in
            CXSetMutedCallAction(call: uuid, muted: false)
        }
    }
    
    func toggleMute() {
        let isOnMute: Bool = pil.audio.isMicrophoneMuted
        
        if isOnMute {
            unmute()
        } else {
            mute()
        }
    }
    
    public func sendDtmf(_ dtmf: String, playToneLocally: Bool = true) {
        if playToneLocally {
            pil.audio.dtmf.playTone(dtmf)
        }
        performCallAction { uuid -> CXCallAction in
            CXPlayDTMFCallAction(call: uuid, digits: dtmf, type: .singleTone)
        }
    }
    
    public func beginAttendedTransfer(number: String) {
        callExists { call in
            pil.calls.transferSession = voipLib.actions(call: call).beginAttendedTransfer(to: number)
        }
    }
    
    public func completeAttendedTransfer() {
        if let transferSession = pil.calls.transferSession {
            voipLib.actions(call: transferSession.from).finishAttendedTransfer(attendedTransferSession: transferSession)
        }
    }
    
    func performCallAction(_ callback: (UUID) -> CXCallAction) {
        guard let uuid = pil.iOSCallKit.findCallUuid() else { return }
        let action = callback(uuid)
        
        controller.request(CXTransaction(action: action)) { error in
            if error != nil {
                print("Failed to perform \(action.description) \(String(describing: error?.localizedDescription))")
            } else {
                debugPrint("Performed \(action.description))")
            }
        }
    }
   
    private func callExists(callback: (VoipLibCall) -> Void) {
        if let transferSession = pil.calls.transferSession {
            callback(transferSession.to)
            return
        }
        
        if let call = pil.calls.activeVoipLibCall {
            callback(call)
            return
        }
    }
}
