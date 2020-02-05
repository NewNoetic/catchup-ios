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
    
    enum SchedulerError: Error {
        case noTomorrow
    }
    
    /// Represents a time slot in a day
    struct Slot {
        /// Seconds since start of day
        var start: TimeInterval
        
        /// Seconds since start of day
        var end: TimeInterval
    }
    
    let calendar = Calendar(identifier: .gregorian)
    
    func schedule() {
        let catchups = (try? Database.shared.allCatchups()) ?? []
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
            
            guard let nextTouch = try? nextOpenSlot(startDate: startOfTomorrow, alreadySheduled: scheduledSlots, weekdayAvailability: weekdaySlots, weekendAvailability: weekendSlots, slotDuration: slotDuration) else {
                return /* TODO: log error */
            }
            
            let scheduledCatchup = Catchup(contact: catchup.contact, interval: slotDuration, method: catchup.method, nextTouch: nextTouch.start, nextNotification: "") // TODO: actually schedule the notification and add the notification ID to nextNotification
            do {
                try Database.shared.upsert(catchup: scheduledCatchup)
            } catch {
                print("Error saving catchup after saving it to the DB... \(error.localizedDescription)")
            }
        }
    }
    
    func nextOpenSlot(startDate: Date, alreadySheduled: [DateInterval], weekdayAvailability: [Slot], weekendAvailability: [Slot], slotDuration: TimeInterval) throws -> DateInterval {
        var trackingDate = Date(timeInterval: 0, since: startDate)
        while true {
            let isConflictingSlot = alreadySheduled.filter { $0.intersects(DateInterval(start: trackingDate, duration: slotDuration)) }.count > 0
            guard isConflictingSlot == false else { trackingDate.addTimeInterval(slotDuration); continue }
            guard let startOfTheDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: trackingDate) else { throw SchedulerError.noTomorrow }
            let dailyAvailability = calendar.isDateInWeekend(trackingDate) ? weekendAvailability : weekdayAvailability
            
            var nextOpenSlot: DateInterval?
            for availableSlot in dailyAvailability {
                let availableInterval = DateInterval(start: Date(timeInterval: availableSlot.start, since: startOfTheDay), end: Date(timeInterval: availableSlot.end, since: startOfTheDay))
                let openSlotCandidate = DateInterval(start: trackingDate, duration: slotDuration)
                if (availableInterval.intersects(openSlotCandidate)) {
                    nextOpenSlot = openSlotCandidate
                }
            }
            
            guard let returnOpenSlot = nextOpenSlot else {
                trackingDate.addTimeInterval(slotDuration)
                continue
            }
            
            return returnOpenSlot
        }
    }
}
