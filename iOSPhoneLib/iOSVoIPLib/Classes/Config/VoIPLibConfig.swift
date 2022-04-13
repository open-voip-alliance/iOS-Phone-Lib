//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation

public typealias LogListener = (String) -> Void

public struct VoIPLibConfig {
    public init(callDelegate: VoIPLibCallDelegate, stun: String? = nil, ring: String? = nil, codecs: [Codec] = [Codec.OPUS], userAgent: String = "iOSVoIPLib", logListener: @escaping LogListener) {
        self.callDelegate = callDelegate
        self.stun = stun
        self.ring = ring
        self.codecs = codecs
        self.userAgent = userAgent
        self.logListener = logListener
    }
    
    public let callDelegate: VoIPLibCallDelegate
    public let stun: String?
    public let ring: String?
    public let codecs: [Codec]
    public let userAgent: String
    public let logListener: LogListener
}
