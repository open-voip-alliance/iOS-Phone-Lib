import Foundation

public struct Preferences: Equatable {
    public let useApplicationRingtone: Bool
    @available(*, deprecated, message: "Codecs are no longer configurable")
    public let codecs: [Codec] = [Codec.OPUS]
    public let includesCallsInRecents: Bool
    
    
    @available(*, deprecated, message: "Codecs are no longer configurable")
    public init(useApplicationRingtone: Bool = true, codecs: [Codec] = [Codec.OPUS], includesCallsInRecents: Bool = false) {
        self.useApplicationRingtone = useApplicationRingtone
        self.includesCallsInRecents = includesCallsInRecents
    }
    
    public init(useApplicationRingtone: Bool = true, includesCallsInRecents: Bool = false) {
        self.useApplicationRingtone = useApplicationRingtone
        self.includesCallsInRecents = includesCallsInRecents
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.useApplicationRingtone == rhs.useApplicationRingtone && lhs.includesCallsInRecents == rhs.includesCallsInRecents
    }
}
