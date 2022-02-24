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
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addressBookDidChange),
            name: NSNotification.Name.CNContactStoreDidChange,
            object: nil)
    }
    
    
    func find(number: String) -> Contact? {
        let contact = self.cachedContacts[number]
        
        if contact == nil {
            store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    self.performBackgroundLookup(number: number)
                }
            }
        }
        
        if let contact = contact {
            return contact
        }
        
        return nil
    }
    
    private func performBackgroundLookup(number: String) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                if !contact.phoneNumbers.filter({ $0.value.stringValue.filter("+0123456789".contains) == number }).isEmpty {
                    self.cachedContacts[number] = Contact(
                        name: "\(contact.givenName) \(contact.familyName)",
                        image: nil //contact.imageData //wip this causes exception
                    )
                    return
                }
                
                self.cachedContacts[number] = nil
            })
        } catch {
            print("Unable to access contacts")
        }
    }
    
    @objc func addressBookDidChange() {
        cachedContacts.removeAll()
    }
}

public struct Contact {
    public let name: String
    public let image: Data?
}
