//
//  Actions.swift
//  iOSVoIPLib
//
//  Created by Jeremy Norman on 02/03/2021.
//

import Foundation

public class Actions {
    
    let linphone: LinphoneManager
    let call: Call
    
    init(linphone: LinphoneManager, call: Call) {
        self.linphone = linphone
        self.call = call
    }
    
    /// Accept an incoming call
    ///
    /// - Parameters:
    ///     - call: The accepting call
    /// - Returns: `Bool` Whether accepting went successfully
    public func accept() -> Bool {
        linphone.acceptCall(for: call)
    }
    
    /// End an call.
    ///
    /// - Parameters:
    ///     - call: The accepting call
    /// - Returns: `Bool` Whether ending went successfully
    public func end() -> Bool {
        linphone.endCall(for: call)
    }
    
    /// Enable/disable the audio call.
    /// This is a `CallKit` support function. Which must be called by the `CXProviderDelegate` on `didActivate` and `didDeactivate`.
    ///
    /// - Parameters:
    ///     - enabled: State of audio
    public func setAudio(enabled:Bool) {
        linphone.setAudio(enabled: enabled)
    }
    
    /// Set a call on (un)hold
    ///
    /// - Parameters:
    ///     - call: The call
    ///     - onHold: The new hold state
    /// - Returns: `Bool` Whether the change was successful.
    public func hold(onHold hold:Bool) -> Bool {
        linphone.setHold(call: call, onHold: hold)
    }
    
    /// Transfer a call. This is unattended.
    ///
    /// - Parameters:
    ///     - call: The active call
    ///     - number: Transfer to number
    /// - Returns: `Bool` Whether the transfer was successful.
    public func transfer(to number:String) -> Bool {
        linphone.transfer(call: call, to: number)
    }
    
    /// Begin process of attended transfer by calling the transfer target's number.
    ///
    /// - Parameters:
    ///     - call: The active call
    ///     - number: The transfer target's number
    /// - Returns: `AttendedTransferCall` The struct with the two calls.
    public func beginAttendedTransfer(to number:String) -> AttendedTransferSession? {
        linphone.beginAttendedTransfer(call: call, to:number)
    }
    
    /// Finish process of attended transfer by merging the calls.
    ///
    /// - Parameter:
    ///     - attendedTransferCall: The struct with the two calls.
    /// - Returns: `Bool` Whether the transfer was successful.
    public func finishAttendedTransfer(attendedTransferSession:AttendedTransferSession) -> Bool {
        linphone.finishAttendedTransfer(attendedTransferSession:attendedTransferSession)
    }
    
    /// Send Dtmf.
    ///
    /// - Parameter:
    ///     - call: The call with the active call.
    ///     - dtmf: The string with the dtmf digits.
    public func sendDtmf(dtmf: String) {
        linphone.sendDtmf(call: call, dtmf: dtmf)
    }
    
    /// Get call information.
    ///
    /// - Returns: A string with the call info, empty when could not get any.
    public func callInfo() -> String {
        linphone.provideCallInfo(call: call)
    }
}
