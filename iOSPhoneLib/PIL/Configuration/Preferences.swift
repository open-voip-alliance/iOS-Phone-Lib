import Foundation

public struct Preferences: Equatable {
    public let useApplicationRingtone: Bool
    public let includesCallsInRecents: Bool
    public let supplementaryContacts: Set<SupplementaryContact>
    
    public init(useApplicationRingtone: Bool = true, includesCallsInRecents: Bool = false, supplementaryContacts: Set<SupplementaryContact> = []) {
        self.useApplicationRingtone = useApplicationRingtone
        self.includesCallsInRecents = includesCallsInRecents
        self.supplementaryContacts = supplementaryContacts
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.useApplicationRingtone == rhs.useApplicationRingtone && lhs.includesCallsInRecents == rhs.includesCallsInRecents && lhs.supplementaryContacts == rhs.supplementaryContacts
    }
}
