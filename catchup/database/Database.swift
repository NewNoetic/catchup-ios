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

/// Allows us to store and retreive `CNContact`s from the db
extension CNContact: Value {
    public static var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ blobValue: Blob) -> CNContact {
        return try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [CNContact.self], from: Data.fromDatatypeValue(blobValue)) as! CNContact
    }
    
    public var datatypeValue: Blob {
        return try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false).datatypeValue
    }
    
    public typealias Datatype = Blob
}

extension Connection {
    public var userVersion: Int32 {
        get { return Int32(((try? scalar("PRAGMA user_version")) ?? 0) as? Int64 ?? 0)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

let contact = Expression<CNContact>("contact")
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
        try createCatchupsTable()
    }
    
    func createCatchupsTable() throws {
        try db.run(catchups.create(ifNotExists: true) { t in
            t.column(contact, primaryKey: true)
            t.column(interval)
            t.column(method)
            t.column(nextTouch)
            t.column(nextNotification)
        })
    }
    
    func allCatchups() throws -> [Catchup] {
        return try db.prepare(catchups.order(nextTouch.asc)).compactMap({ (row: Row) -> Catchup? in
            return Catchup(contact: row[contact], interval: row[interval], method: ContactMethod(rawValue: row[method]) ?? ContactMethod.call, nextTouch: row[nextTouch], nextNotification: row[nextNotification])
        })
    }
    
    func catchup(notification: String) -> Catchup? {
        do {
            return try db.prepare(catchups.where(nextNotification == notification)).compactMap({ row -> Catchup? in
                return Catchup(contact: row[contact], interval: row[interval], method: ContactMethod(rawValue: row[method]) ?? ContactMethod.call, nextTouch: row[nextTouch], nextNotification: row[nextNotification])
            }).first
        } catch {
            return nil
        }
    }
    
    func upsert(catchup: Catchup) throws {
        var setters = [
            contact <- catchup.contact, interval <- catchup.interval, method <- catchup.method.rawValue
        ]
        if let nt = catchup.nextTouch {
            setters.append(nextTouch <- nt)
        }
        if let nn = catchup.nextNotification {
            setters.append(nextNotification <- nn)
        }
        try db.run(catchups.insert(or: .replace, setters))
    }
    
    func remove(catchup: Catchup) throws {
        let toDelete = catchups.filter(contact == catchup.contact)
        try db.run(toDelete.delete())
    }
    
    func deleteAll() throws {
        try db.run(self.catchups.delete())
    }
    
    func dropCatchupsTable() throws {
        try db.run(catchups.drop(ifExists: true))
    }
}
