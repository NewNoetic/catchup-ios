//
//  Notifications.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/6/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import UserNotifications
import Combine

extension Future where Output: Any, Failure: Error {}

struct Notifications {
    static let _shared = Notifications()
    func schedule(catchup: Catchup) -> String {
        // TODO: implement
    }
}

struct UserNotificationsAsync {
    static let center = UNUserNotificationCenter.current()
    
    static func authenticate() -> Future<Void, Error> {
        let future = Future<Void, Error> { promise in
            self.center.requestAuthorization(options: [.alert]) { (granted, error) in
                granted ? promise(.success(())) : promise(.failure(NotificationsError.authorizationError))
            }
        }
        return future
    }
    
    static func authenticaticated() -> Future<Void, Error> {
        let future = Future<Void, Error> { (@Await promise) in
            self.center.getNotificationSettings { settings in
                settings.authorizationStatus == .authorized ? promise(.success(())) : promise(.failure(NotificationsError.authorizationError))
            }
        }
        return future
    }
}

enum NotificationsError: Error {
    case authorizationError
}

// Was trying something cool here to allow "await" on futures, but I don't think it'll work out.
//@propertyWrapper
//struct Await<V: Any, E: Error> {
//    var value: V
//    var error: E
//
//    init(wrappedValue: V, wrappedError: E) {
//        value = wrappedValue
//        error = wrappedError
//    }
//
//    var wrappedValue: V {
//        get {}
//        set {}
//    }
//}
