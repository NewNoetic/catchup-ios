//
//  Scheduler.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/4/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

struct Scheduler {
    static let shared = Scheduler()
    
    /// Represents a time slot in a day
    struct Slot {
        /// Seconds since start of day
        var start: TimeInterval
        
        /// Seconds since start of day
        var end: TimeInterval
    }
    
    func schedule() {
        let catchups = (try? Database.shared.allCatchups()) ?? []
        let calendar = Calendar(identifier: .gregorian)
        let weekdaySlots = [Slot(start: 64800, end: 68400)/* 6pm-7pm */]
        let weekendSlots = [Slot(start: 36000, end: 79200)/*10am-10pm*/]
        let slotDuration = TimeInterval(1800) // 30 mins
        let today = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return /* TODO: log error */ }
        guard let startOfTomorrow = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else { return /* TODO: log error */ }
        
        let scheduledSlots = catchups
            .compactMap { (catchup) -> DateInterval? in
                guard let nextTouch = catchup.nextTouch, let _ = catchup.nextNotification else { return nil }
                return DateInterval(start: nextTouch, duration: slotDuration)
        }
        .sorted { (a: DateInterval, b: DateInterval) -> Bool in
            return a.start.compare(b.start) == ComparisonResult.orderedAscending
        }
                
        for catchup in catchups {
            guard (catchup.nextNotification == nil || catchup.nextTouch == nil) else {
                return // if already scheduled, don't schedule
            }
            
            let nextSlotStart = calendar.isDateInWeekend(startOfTomorrow)
                ? Date(timeInterval: weekendSlots[0].start, since: startOfTomorrow)
                : Date(timeInterval: weekdaySlots[0].start, since: startOfTomorrow)
            var nextSlot = DateInterval(start: nextSlotStart, duration: slotDuration)
            
            var scheduled = false
            while (!scheduled) {
                let overlapping = scheduledSlots.filter { scheduledSlot in
                    return scheduledSlot.intersects(nextSlot)
                }.count > 0
                if (overlapping) {
                    nextSlot.start = nextSlot.start.addingTimeInterval(slotDuration) // TODO: This needs to respect the available slots timings for the day
                } else {
                    // TODO: Schedule notification, attach it to the catchup and upsert it to the DB
                    scheduled = true
                }
            }
        }
    }
}
