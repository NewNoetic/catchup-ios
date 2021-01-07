//
//  Upcoming.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Combine
import UserNotifications

final class Upcoming: ObservableObject {
    enum Display {
        case standard
        case debug
    }
    
    @Published var catchups: [Catchup] = []
    @Published var display: Display = .standard
    
    init(catchups: [Catchup] = []) {
        self.catchups = catchups
    }
    
    func update() {
        guard let dbCatchups = try? Database.shared.allCatchups() else { return }
        self.catchups = dbCatchups
        
        // When updating, also grab any exprired catchups and reschedule them
        if let expiredCatchups = try? Database.shared.expiredCatchups() {
            Scheduler.shared.reschedule(expiredCatchups)
                .then { scheduledOrError in
                    try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                    scheduledOrError.compactMap { $0.error }.forEach { captureError($0) } // TODO: grab individual errors and catchups from them if provided
                    guard let c = try? Database.shared.allCatchups() else { return }
                    self.catchups = c
            }.catch { (error) in
                captureError(error, message: "Couldn't reschedule expired catchups during update")
            }
        }
        
        // When updating, also delete any pending orphaned notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            let invalidNotificationIdentifiers = notifications.filter { n in
                dbCatchups.first { c in
                    return c.nextNotification == n.identifier
                } == nil
            }.map { n in
                return n.identifier
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: invalidNotificationIdentifiers)
        }
    }
    
    func remove(at offsets: IndexSet) {
        for (index, element) in self.catchups.enumerated() {
            if (offsets.contains(index)) {
                // remove it from the db
                do {
                    try Database.shared.remove(catchup: element)
                } catch {
                    captureError(error, message: "could not delete catchup: \(error.localizedDescription)")
                }
                
                // remove the pending notification
                if let notificationIdentifier = element.nextNotification {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationIdentifier])
                }
            }
        }
        self.update()
    }
}
