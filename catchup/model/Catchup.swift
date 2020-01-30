//
//  Catchup.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Contacts

struct Catchup {
    var contact: CNContact
    var interval: TimeInterval
    var method: ContactMethod
    var touches: [Touch]
    static func generateRandom(name: String) -> Catchup {
        let contact = CNMutableContact()
        contact.givenName = name.components(separatedBy: " ")[0]
        contact.familyName = name.components(separatedBy: " ")[1]
        return Catchup(contact: contact, interval: Intervals.day.rawValue, method: .call, touches: [])
    }
}
