//
//  Scheduler.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/4/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import Promises

struct Scheduler {
    static let shared = Scheduler()
    
    enum SchedulerError: Error {
        case noTomorrow
        case noStartOfTomorrow
        case alreadyScheduled
        case noNextSlot(_ catchup: Catchup)
    }
    
    /// Represents a time slot in a day
    struct Slot {
        /// Seconds since start of day
        var start: TimeInterval
        
        /// Seconds since start of day
        var end: TimeInterval
    }
    
    let calendar = Calendar(identifier: .gregorian)
    
    func schedule(_ catchups: [Catchup]) -> Promise<[Maybe<Catchup>]> {
        let weekdaySlots = [Slot(start: 64800, end: 68400)/* 6pm-7pm */]
        let weekendSlots = [Slot(start: 36000, end: 79200)/*10am-10pm*/]
        let slotDuration = TimeInterval(1800) // 30 mins
        let today = Date()
        guard let tomorrow = self.calendar.date(byAdding: .day, value: 1, to: today) else {
            return Promise(SchedulerError.noTomorrow)
        }
        guard let startOfTomorrow = self.calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return Promise(SchedulerError.noTomorrow)
        }
        let dateSort = { (a: DateInterval, b: DateInterval) -> Bool in
            return a.start.compare(b.start) == ComparisonResult.orderedAscending
        }
        
        var scheduledSlots: [DateInterval] = ((try? Database.shared.allCatchups()) ?? [])
        .compactMap { (catchup) -> DateInterval? in
                guard let nextTouch = catchup.nextTouch, let _ = catchup.nextNotification else { return nil }
                return DateInterval(start: nextTouch, duration: slotDuration)
        }
        .sorted(by: dateSort)
        
        let catchupsToSchedule = catchups.filter { (c) -> Bool in
            return c.nextNotification == nil || c.nextTouch == nil
        }
        
        let scheduledCatchups = catchupsToSchedule.map { catchup -> Promise<Catchup> in
            guard let nextTouch = try? self.nextOpenSlot(startDate: startOfTomorrow, alreadySheduled: scheduledSlots, weekdayAvailability: weekdaySlots, weekendAvailability: weekendSlots, slotDuration: slotDuration) else {
                return Promise(SchedulerError.noNextSlot(catchup))
                // TODO: Do something to recover?
            }
            
            var unscheduledCatchup = catchup
            unscheduledCatchup.nextTouch = nextTouch.start
            
            scheduledSlots.append(nextTouch)
            scheduledSlots.sort(by: dateSort)
            
            return Notifications.shared.schedule(catchup: unscheduledCatchup)
        }
        
        return any(scheduledCatchups)
    }
    
    func nextOpenSlot(startDate: Date, alreadySheduled: [DateInterval], weekdayAvailability: [Slot], weekendAvailability: [Slot], slotDuration: TimeInterval) throws -> DateInterval {
        var trackingDate = Date(timeInterval: 1, since: startDate) // need to add one second to make it not overlap with end of previous slot when comparing by "minute"
        while true {
            let isConflictingSlot = alreadySheduled.filter { $0.intersects(DateInterval(start: trackingDate, duration: slotDuration - 1)) }.count > 0
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
