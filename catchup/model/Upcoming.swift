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
    @Published var catchups: [Catchup] = []
    
    func update() {
        guard let c = try? Database.shared.allCatchups()
            else { return }
        self.catchups = c
    }
    
    func remove(at offsets: IndexSet) {
        for (index, element) in self.catchups.enumerated() {
            if (offsets.contains(index)) {
                // remove it from the db
                do {
                    try Database.shared.remove(catchup: element)
                } catch {
                    print("could not delete catchup: \(error.localizedDescription)")
                }
                
                // remove the pending notification
                if let notificationIdentifier = element.nextNotification {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                }
            }
        }
        self.update()
    }
}
