//
//  Contacts.swift
//  PIL
//
//  Created by Jeremy Norman on 07/03/2021.
//

import Foundation
import Contacts

typealias ContactCallback = (Contact?) -> Void

class Contacts {
    
    private let store = CNContactStore()
    
    private var cachedContacts = [String: Contact?]()
    
    private let preferences: CurrentPreferencesResolver
    
    init(preferences: @escaping CurrentPreferencesResolver) {
        self.preferences = preferences
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addressBookDidChange),
            name: NSNotification.Name.CNContactStoreDidChange,
            object: nil
        )
    }
    
    
    func find(call: VoIPLibCall) -> Contact? {
        find(number: call.remoteNumber, identifier: call.identifier)
    }
    
    func find(number: String, identifier: String)  -> Contact? {
        if let contact = self.cachedContacts[identifier] {
            if let contact = contact {
                return contact.exists ? contact : nil
            }
        }
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                self.performBackgroundLookup(number: number, identifier: identifier)
            }
        }
        
        if cachedContacts[identifier] == nil, let contact = preferences().supplementaryContacts.find(forNumber: number) {
            cachedContacts[identifier] = contact.toContact()
        }
        
        return cachedContacts[identifier, default: nil]
    }
    
    private func performBackgroundLookup(number: String, identifier: String) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                if !contact.phoneNumbers.filter({ $0.value.stringValue.normalizePhoneNumber() == number }).isEmpty {
                    self.cachedContacts[identifier] = Contact("\(contact.givenName) \(contact.familyName)")
                    return
                }
                
                if cachedContacts[identifier] == nil {
                    cachedContacts[identifier] = Contact.notFound()
                }
            })
        } catch {
            log("Unable to access contacts")
        }
    }
    
    internal func clearCache() {
        cachedContacts.removeAll()
    }
    
    @objc func addressBookDidChange() {
        clearCache()
    }
}

public struct Contact {
    public let name: String
    public let image: Data?
    
    internal var exists: Bool {
        return !name.isEmpty
    }
    
    init(_ name: String) {
        self.name = name
        self.image = nil
    }
    
    init() {
        self.init("")
    }
    
    public static func notFound() -> Contact {
        return Contact()
    }
}

extension VoIPLibCall {
    var identifier: String {
        return callId.description
    }
}

extension String {
    func normalizePhoneNumber() -> String {
        return replacingOccurrences(of: "[^0-9\\+]", with: "", options: .regularExpression)
    }
}

extension Set<SupplementaryContact> {
    func find(forNumber number: String) -> SupplementaryContact? {
        return first(where: {$0.number.normalizePhoneNumber() == number})
    }
}
