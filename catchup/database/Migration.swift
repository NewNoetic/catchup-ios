//
//  Migration.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/11/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

struct Migration {
    static func run() {
        let db = Database.shared.db
        let catchupsTable = Database.shared.catchups
        
        if db.userVersion == 0 {
            defer { db.userVersion = 1 }
            print("running db migration from 0 to 1")
            do {
                try db.transaction {
                    try db.run(catchupsTable.drop(ifExists: true))
                    try Database.shared.createCatchupsTable()
                }
            } catch {
                print("error running migration \(error.localizedDescription)")
            }
        }
//        if db.userVersion == 1 {
//            print("running db migration from 1 to 2")
//            // handle second migration
//            db.userVersion = 2
//        }
    }
}
