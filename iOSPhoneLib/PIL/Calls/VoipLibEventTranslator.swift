//
//  VoipLibEventTranslator.swift
//  PIL
//
//  Created by Jeremy Norman on 04/03/2021.
//

import Foundation
import CallKit

class VoipLibEventTranslator: VoIPLibCallDelegate {
    
    private let pil: PIL
    
    init(pil: PIL) {
        self.pil = pil
    }
    
    // MARK: CallDelegate methods
    public func incomingCallReceived(_ incomingCall: VoIPLibCall) {
        pil.writeLog("VoipLib event incomingCallReceived: \(incomingCall.callId)")
        
        if (pil.calls.isInCall) {
            pil.writeLog("Ignoring incoming call: \(incomingCall.callId) as we are in a call already")
            return
        }
        
        pil.writeLog("Setting up the incoming call")
        
        pil.calls.add(voipLibCall: incomingCall)
        
        pil.events.broadcast(event: .incomingCallReceived(state: pil.sessionState))
    }

    public func outgoingCallCreated(_ call: VoIPLibCall) {
        pil.writeLog("VoipLib event outgoingCallCreated: \(call.callId)")
        
        pil.calls.add(voipLibCall: call)
        
        if (pil.calls.isInTransfer) {
            pil.events.broadcast(event: .attendedTransferStarted(state: pil.sessionState))
        } else {
            pil.writeLog("Setting up the outgoing call")
            pil.events.broadcast(event: .outgoingCallStarted(state: pil.sessionState))
        }
    }

    public func callUpdated(_ call: VoIPLibCall, message: String) {
        pil.writeLog("VoipLib event callUpdated")
        pil.events.broadcast(event: .callStateUpdated(state: pil.sessionState))
    }

    public func callConnected(_ call: VoIPLibCall) {
        pil.writeLog("VoipLib event callConnected")
              
        pil.voipLib.actions(call: call).setAudio(enabled: true)
        
        if pil.calls.isInTransfer {
            pil.events.broadcast(event: .attendedTransferConnected(state: pil.sessionState))
        } else {
            pil.events.broadcast(event: .callConnected(state: pil.sessionState))
        }
        
        /// For outbound calls the audio route is changed when the call is connected to the phone (from bluetooth), as a workaround
        /// we will route this back to the default input after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.pil.calls.isInTransfer {
                self.pil.audio.routeToDefault()
            }
        }
    }

    public func callEnded(_ call: VoIPLibCall) {
        pil.writeLog("VoipLib event callEnded")
        
        let currentSessionState = pil.sessionState
        let isInTransfer = pil.calls.isInTransfer
        
        pil.calls.remove(voipLibCall: call)
        
        if isInTransfer {
            pil.writeLog("Call ended in transfer")
            pil.events.broadcast(event: .attendedTransferAborted(state: currentSessionState))
        } else {
            pil.events.broadcast(event: .callEnded(state: currentSessionState))
        }
    }
    
    func attendedTransferMerged(_ call: VoIPLibCall) {
        pil.writeLog("VoipLib event attendedTransferMerged")
        
        pil.calls.remove(voipLibCall: call)
        
        pil.events.broadcast(event: .attendedTransferEnded(state: pil.sessionState))
    }
    
    public func callReleased(_ call: VoIPLibCall) {
        pil.platformIntegrator.notifyIfMissedCall(call: call)
    }
}
