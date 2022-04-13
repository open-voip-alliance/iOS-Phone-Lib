//
//  VoIPLibHelper.swift
//  PIL
//
//  Created by Jeremy Norman on 01/03/2021.
//

import Foundation

class VoIPLibHelper {

    private let voipLib: VoIPLib
    private let pil: PIL
    private let voipLibEventTranslator: VoipLibEventTranslator
    
    init(voipLib: VoIPLib, pil: PIL, voipLibEventTranslator: VoipLibEventTranslator) {
        self.voipLib = voipLib
        self.pil = pil
        self.voipLibEventTranslator = voipLibEventTranslator
    }
    
    /// Boots the VoIP library.
    internal func initialize(force: Bool) {
        if voipLib.isInitialized && !force {
            pil.writeLog("The VoIP library is already initialized, skipping init.")
            return
        }
        
        guard let auth = pil.auth else {
            pil.writeLog("There are no authentication credentials, not registering.")
            return
        }
        
        if (force && voipLib.isInitialized) {
            voipLib.destroy()
        }
        
        if (!voipLib.isInitialized) {
            voipLib.initialize(
                config: createConfig(auth: auth)
            )
        }
    }

    /// Attempt to register if there are valid credentials.
    internal func register(auth: Auth, force: Bool = false, callback: @escaping (Bool) -> Void) {
        guard let auth = pil.auth else {
            pil.writeLog("There are no authentication credentials, not registering.")
            return
        }
        
        voipLib.swapConfig(config: createConfig(auth: auth))
        
        if voipLib.isRegistered && !force {
            pil.writeLog("We are already registered!")
            callback(true)
            return
        }
        
        pil.writeLog("Attempting registration...")
        
        voipLib.register { state in
            self.pil.writeLog("Registration response: \(state)")
            
            if state == .registered {
                self.pil.writeLog("Registration was successful!")
                callback(true)
            }
            else if state == .failed {
                self.pil.writeLog("Registration failed.")
                callback(false)
            }
        }
    }
    
    /// Create configuration object using authentication details
    /// - Parameter auth: authentication details object
    /// - Returns: configuration object
    private func createConfig(auth: Auth) -> VoIPLibConfig {
        VoIPLibConfig(
            callDelegate: voipLibEventTranslator,
            userAgent: self.pil.app.userAgent,
            logListener: { message in
                self.pil.app.logDelegate?.onLogReceived(message: message, level: LogLevel.info)
            }
        )
    }
}
