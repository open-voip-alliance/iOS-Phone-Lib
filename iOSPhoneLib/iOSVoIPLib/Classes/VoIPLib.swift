//
//  SpindleSIPFramework.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

class VoIPLib {
    
    static public let shared = VoIPLib()
    
    var isInitialized: Bool {
        get { linphone.isInitialized }
    }
    
    var config: VoIPLibConfig? {
        linphone.config
    }
    
    var audio: LinphoneAudio {
        linphone.linphoneAudio
    }
    
    let linphone: LinphoneManager
    
    init() {
        linphone = LinphoneManager()
    }
    
    func initialize(config: VoIPLibConfig) {
        if (!isInitialized) {
            _ = linphone.initialize(config: config)
        }
    }
    
    /// This `registers` your user on SIP. You need this before placing a call.
    /// - Returns: Bool containing register result
    func register(callback: @escaping RegistrationCallback) {
        linphone.register(callback: callback)
    }
    
    func refreshRegistration() {
        linphone.refreshRegistration()
    }

    func destroy() {
        linphone.destroy()
    }
    
    func terminateAllCalls() {
        linphone.terminateAllCalls()
    }
    
    /// This `unregisters` your user on SIP.
    ///
    /// - Parameters:
    ///     - finished: Called async when unregistering is done.
    func unregister() {
        linphone.unregister()
    }
    
    /// Call a phone number
    ///
    /// - Parameters:
    ///     - number: The phone number to call
    /// - Returns: Returns true when call succeeds, false when the number is an empty string or the phone service isn't ready.
    func call(to number: String) -> Bool {
        return linphone.call(to: number) != nil
    }
    
    var isMicrophoneMuted:Bool {
        get {
            linphone.isMicrophoneMuted
        }
        
        set(muted) {
            linphone.setMicrophone(muted: muted)
        }
    }
    
    func actions(call: VoIPLibCall) -> Actions {
        Actions(linphoneManager: linphone, call: call)
    }
}
