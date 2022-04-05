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
print("REGISTERING FOR PUSH")
        if let token = token {
            print("TOKEN received?")
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
        
        pil.iOSCallKit.reportIncomingCall(detail: IncomingPayloadCallDetail(phoneNumber: "0123123123", callerId: "test123"))
        
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
                
        pil.start() { success in
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
                print("TEST123 Push token nil")
                return nil
            }
            print("TEST123 token=\(token)")

            return String(apnsToken: token)
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = String(apnsToken: pushCredentials.token)
        print("Received a new APNS token: \(token)")

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
