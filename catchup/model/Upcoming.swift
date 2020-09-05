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
    
    func update() {
        // When updating, also grab any exprired catchups and reschedule them
        let expiredCatchups = (try? Database.shared.expiredCatchups()) ?? []
        Scheduler.shared.reschedule(expiredCatchups)
            .then { scheduledOrError in
                try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
                guard let c = try? Database.shared.allCatchups() else { return }
                self.catchups = c
        }.catch { (error) in
            print(error.localizedDescription)
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
