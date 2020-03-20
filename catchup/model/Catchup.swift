//
//  Catchup.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI
import UserNotifications

struct Catchup: Identifiable {
    var id: String {
        return contact.identifier
    }
    
    /// Get the most relevant phone number from the contact
    /// TODO: Try to pick mobile number?
    var phoneNumber: String? {
        return contact.phoneNumbers.first?.value.stringValue.filter{ $0.isNumber }
    }
    
    var email: String? {
        return contact.emailAddresses.first?.value as String?
    }
    
    var contact: CNContact
    var interval: TimeInterval
    var method: ContactMethod
    var nextTouch: Date?
    var nextNotification: String?
    
    static func generateRandom(name: String, interval: TimeInterval = Intervals.day.value, nextTouch: Date? = nil, nextNotification: String? = nil) -> Catchup {
        let contact = CNMutableContact()
        contact.givenName = name.components(separatedBy: " ")[0]
        contact.familyName = name.components(separatedBy: " ")[1]
        return generateRandom(contact: contact, interval: interval, nextTouch: nextTouch, nextNotification: nextNotification)
    }
    
    static func generateRandom(contact: CNContact, interval: TimeInterval = Intervals.day.value, method: ContactMethod = .email, nextTouch: Date? = nil, nextNotification: String? = nil) -> Catchup {
        return Catchup(contact: contact, interval: interval, method: method, nextTouch: nextTouch, nextNotification: nextNotification)
    }
}
