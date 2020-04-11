//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/28/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Combine

final class Settings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @propertyWrapper
    struct UserDefault<T> {
        let key: String
        let defaultValue: T
        
        init(_ key: String, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }
        
        var wrappedValue: T {
            get {
                return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
        
    @UserDefault("settings.timeslotDuration", defaultValue: TimeInterval(30*60)) var timeslotDuration: TimeInterval { willSet { objectWillChange.send() } }
    
    var timeslotOptions: [TimeInterval] = [3600, 3600*2, 3600*3, 3600*4, 3600*5, 3600*6, 3600*7, 3600*8, 3600*9, 3600*10, 3600*11, 3600*12, 3600*13, 3600*14, 3600*15, 3600*16, 3600*17, 3600*18, 3600*19, 3600*20, 3600*21, 3600*22, 3600*23]
    
    @UserDefault("settings.weekdayTimelslotStartIndex", defaultValue: 17) var weekdayTimeslotStartIndex: Int { willSet { objectWillChange.send() } }
    @UserDefault("settings.weekdayTimeslotEndIndex", defaultValue: 19) var weekdayTimeslotEndIndex: Int { willSet { objectWillChange.send() } }
    @UserDefault("settings.weekendTimelslotStartIndex", defaultValue: 9) var weekendTimeslotStartIndex: Int { willSet { objectWillChange.send() } }
    @UserDefault("settings.weekendTimeslotEndIndex", defaultValue: 21) var weekendTimeslotEndIndex: Int { willSet { objectWillChange.send() } }
    
    func weekdayTimeslots() -> [Slot] {
        return [Slot(start: timeslotOptions[weekdayTimeslotStartIndex], end: timeslotOptions[weekdayTimeslotEndIndex])]
    }
    
    func weekendTimeslots() -> [Slot] {
        return [Slot(start: timeslotOptions[weekendTimeslotStartIndex], end: timeslotOptions[weekendTimeslotEndIndex])]
    }
}
