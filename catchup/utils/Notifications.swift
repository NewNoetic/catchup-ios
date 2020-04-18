//
//  Notifications.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/6/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import UserNotifications
import Contacts
import Promises

struct Notifications {
    static let shared = Notifications()
    func schedule(catchup: Catchup) -> Promise<Catchup> {
        UserNotificationsAsync.authenticaticated()
            .then { _ in
                Promise { resolve, reject in
                guard let date = catchup.nextTouch else {
                    reject(NotificationsError.noDate(catchup))
                    return
                }
                let notification = UNMutableNotificationContent()
                notification.title = "Catch up with \(catchup.contact.displayName)"
                notification.body = "Tap to \(catchup.method.rawValue)"
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date), repeats: false)
                let uuid = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuid, content: notification, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    guard error == nil else {
                        reject(NotificationsError.userNotificationCenterFailed)
                        return
                    }
                    var scheduledCatchup = catchup
                    scheduledCatchup.nextNotification = uuid
                    resolve(scheduledCatchup)
                }
            }
        }
    }
}

struct UserNotificationsAsync {
    static let center = UNUserNotificationCenter.current()
    
    static func authenticate() -> Promise<Void> {
        Promise { resolve, reject in
            self.center.requestAuthorization(options: [.alert]) { granted, error in
                if (granted) {
                    resolve(())
                } else {
                    reject(NotificationsError.authorization)
                }
            }
        }
    }
    
    static func authenticaticated() -> Promise<Void> {
        Promise { resolve, reject in
            self.center.getNotificationSettings { settings in
                if (settings.authorizationStatus == .authorized) {
                    resolve(())
                } else {
                    reject(NotificationsError.authorization)
                }
            }
        }
    }
}

enum NotificationsError: Error {
    case noDate(_ catchup: Catchup)
    case authorization
    case userNotificationCenterFailed
}
