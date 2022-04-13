//
//  SpindleSIPFramework.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

public class VoIPLib {
    
    static public let shared = VoIPLib()

    public var isRegistered: Bool {
        get { linphone.isRegistered }
    }

    public var isInitialized: Bool {
        get { linphone.isInitialized }
    }

    public var isReady: Bool {
        get { isRegistered && isInitialized }
    }
    
    public var config: Config? {
        get {
            linphone.config
        }
    }
    
    let linphone: LinphoneManager
    
    init() {
        linphone = LinphoneManager()
    }
    
    public func initialize(config: Config) {
        if (!isInitialized) {
            _ = linphone.initialize(config: config)
        }
    }

    public func refreshConfig(config: Config) {
        destroy()
        initialize(config: config)
    }

    public func swapConfig(config: Config) {
        linphone.swapConfig(config: config)
    }
    
    /// This `registers` your user on SIP. You need this before placing a call.
    /// - Returns: Bool containing register result
    public func register(callback: @escaping RegistrationCallback) {
        linphone.register(callback: callback)
    }

    public func destroy() {
        linphone.destroy()
    }
    
    public func terminateAllCalls() {
        linphone.terminateAllCalls()
    }
    
    /// This `unregisters` your user on SIP.
    ///
    /// - Parameters:
    ///     - finished: Called async when unregistering is done.
    public func unregister(finished:@escaping() -> ()) {
        linphone.unregister(finished: finished)
    }
    
    /// Call a phone number
    ///
    /// - Parameters:
    ///     - number: The phone number to call
    /// - Returns: Returns true when call succeeds, false when the number is an empty string or the phone service isn't ready.
    public func call(to number: String) -> Bool {
        return linphone.call(to: number) != nil
    }
    
    public var isMicrophoneMuted:Bool {
        get {
            linphone.isMicrophoneMuted
        }
        
        set(muted) {
            linphone.setMicrophone(muted: muted)
        }
        
    }
    
    public func actions(call: Call) -> Actions {
        Actions(linphone: linphone, call: call)
    }
}

internal func log(_ message: String) {
    VoIPLib.shared.config?.logListener(message)
}
