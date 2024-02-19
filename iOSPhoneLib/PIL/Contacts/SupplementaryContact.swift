import Foundation

public struct SupplementaryContact: Hashable {
    public let number: String
    public let name: String
    public let image: Data?
    
    public init(number: String, name: String, image: Data? = nil) {
        self.number = number
        self.name = name
        self.image = image
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(number)
        hasher.combine(name)
        return hasher.finalize()
    }
}

extension SupplementaryContact {
    func toContact() -> Contact {
        return Contact(name)
    }
}
