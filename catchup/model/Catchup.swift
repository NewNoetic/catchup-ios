//
//  Catchup.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Contacts
import UserNotifications

struct Catchup: Identifiable {
    var id: String {
        return contact.identifier
    }
    
    var contact: CNContact
    var interval: TimeInterval
    var method: ContactMethod
    var nextTouch: Date?
    var nextNotification: String?
    
    static func generateRandom(name: String, interval: TimeInterval = Intervals.day.value(), nextTouch: Date? = nil, nextNotification: String? = nil) -> Catchup {
        let contact = CNMutableContact()
        contact.givenName = name.components(separatedBy: " ")[0]
        contact.familyName = name.components(separatedBy: " ")[1]
        return Catchup(contact: contact, interval: interval, method: .call, nextTouch: nextTouch, nextNotification: nextNotification)
    }
}
