//
//  Database.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Contacts
import SQLite

let contactStore = CNContactStore()
let contactKeys = [CNContactIdentifierKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor]

let contact = Expression<String>("contact_id")
let interval = Expression<TimeInterval>("interval")
let method = Expression<String>("method")
let nextTouch = Expression<Date?>("next_touch")
let nextNotification = Expression<String?>("next_notification")

struct Database {
    static let shared = try! Database()
    var db: Connection
    var catchups: Table
    
    private init() throws {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try Connection("\(path)/db.sqlite3")
        catchups = Table("catchups")
        try db.run(catchups.create(ifNotExists: true) { t in
            t.column(contact)
            t.column(interval)
            t.column(method)
            t.column(nextTouch)
            t.column(nextNotification)
        })
    }
    
    func allCatchups() throws -> [Catchup]{
        return try db.prepare(catchups).compactMap({ (row: Row) -> Catchup? in
            guard let c = try? contactStore.unifiedContact(withIdentifier: row[contact], keysToFetch: contactKeys)
                else { return nil }
            return Catchup(contact: c, interval: row[interval], method: ContactMethod(rawValue: row[method]) ?? ContactMethod.call, nextTouch: row[nextTouch], nextNotification: row[nextNotification])
        })
    }
    
    func upsert(catchup: Catchup) throws {
        var setters = [
            contact <- catchup.contact.identifier, interval <- catchup.interval, method <- catchup.method.rawValue
        ]
        if (catchup.nextTouch != nil) {
            setters.append(nextTouch <- catchup.nextTouch!)
        }
        if (catchup.nextNotification != nil) {
            setters.append(nextNotification <- catchup.nextNotification!)
        }
        try db.run(catchups.insert(or: .replace, setters))
    }
    
    func remove(catchup: Catchup) throws {
        let toDelete = catchups.filter(contact == catchup.contact.identifier)
        try db.run(toDelete.delete())
    }
    
    func drop(tableName: String) {
        do {
            try db.run(Table(tableName).drop(ifExists: true))
        } catch {
            print("Could not drop table: \(error.localizedDescription)")
        }
    }
}
