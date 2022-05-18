//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation
import PushKit

class PushKitDelegate: NSObject {

    let pil = di.resolve(PIL.self)!
    let middleware: Middleware
    let voipRegistry: PKPushRegistry

    init(middleware: Middleware) {
        self.middleware = middleware
        voipRegistry = PKPushRegistry(queue: nil)
    }

    func registerForVoipPushes() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        if let token = token {
            middleware.tokenReceived(token: token)
        }
    }
}

extension PushKitDelegate: PKPushRegistryDelegate {

    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> ()) {
        if type != .voIP {
            pil.writeLog("Received a non-VoIP push message. Halting processing.")
            completion()
            return
        }
        
        pil.iOSCallKit.reportIncomingCall(
            phoneNumber: payload.dictionaryPayload[pil.app.pushKitPhoneNumberKey] as? String ?? "",
            callerName: payload.dictionaryPayload[pil.app.pushKitCallerNameKey] as? String ?? ""
        )
        
        /// We will delay briefly to let the library initialize in the AppDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.handle(payload: payload, for: type, completion: completion)
        }
    }
    
    private func handle(payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> ()) {
        self.middleware.inspect(payload: payload, type: type)
            
        pil.writeLog("Received a VoIP push message, starting incoming ringing.")
    
        if pil.calls.isInCall {
            pil.writeLog("Not taking call as we already have an active one!")
            self.middleware.respond(payload: payload, available: false, reason: UnavailableReason.inCall)
            completion()
            return
        }
                        
        pil.start { success in
            self.pil.writeLog("PIL started with success=\(success), responding to middleware: \(success)")
            
            if success {
                self.middleware.respond(payload: payload, available: true)
            } else {
                self.middleware.respond(payload: payload, available: false, reason: UnavailableReason.unableToRegister)
            }
            
            completion()
        }
    }

    var token: String? {
        get {
            guard let token = voipRegistry.pushToken(for: PKPushType.voIP) else {
                return nil
            }

            return String(apnsToken: token)
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = String(apnsToken: pushCredentials.token)
        log("Received a new APNS token: \(token)")

        middleware.tokenReceived(token: token)
    }
    
}

extension String {
    public init(apnsToken: Data) {
        self = apnsToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}

public enum UnavailableReason {
    case inCall
    case unableToRegister
}
