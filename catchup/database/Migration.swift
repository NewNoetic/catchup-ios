//
//  Migration.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/11/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import UserNotifications

struct Migration {
    static func run() {
        let db = Database.shared.db
        let catchupsTable = Database.shared.catchups
        
        if db.userVersion == 0 {
            defer {
                db.userVersion = 1
                AppState.shared.startView = .intro1
            }
            print("running db migration from 0 to 1")
            do {
                try db.transaction {
                    try db.run(catchupsTable.drop(ifExists: true))
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    try Database.shared.createCatchupsTable()
                }
            } catch {
                captureError(error, message: "error running migration")
            }
        }
//        if db.userVersion == 1 {
//            print("running db migration from 1 to 2")
//            // handle second migration
//            db.userVersion = 2
//        }
    }
}
