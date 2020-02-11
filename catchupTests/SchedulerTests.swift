//
//  SchedulerTests.swift
//  catchupTests
//
//  Created by Sidhant Gandhi on 2/5/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest
import Promises

class SchedulerTests: XCTestCase {

    let calendar = Calendar(identifier: .gregorian)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNextOpenSlotWeekday() {
        guard let baselineDate = calendar.nextDate(after: Date(), matching:DateComponents(weekday: 2), matchingPolicy: .strict) else { assertionFailure("couldn't create start date"); return }
        
        let dateOnWhichToExpectOpenSlot = baselineDate
        
        assert(!calendar.isDateInWeekend(dateOnWhichToExpectOpenSlot), "start date should be monday, but is weekend")
        assert(dateOnWhichToExpectOpenSlot.compare(Date()) == ComparisonResult.orderedDescending, "start date should be after right now, but it's before")
        
        let weekdayAvailability = [Scheduler.Slot(start: 64800, end: 68400)/* 6pm-7pm */]
        let weekendAvailability: [Scheduler.Slot] = []
        let slotDuration = TimeInterval(1800) // 30 mins
        
        guard let startOfDateOnWhichToExpectOpenSlot = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateOnWhichToExpectOpenSlot) else {
            assertionFailure("could not set start of day for startDate")
            return
        }
        let alreadyScheduled = [
            DateInterval(start: startOfDateOnWhichToExpectOpenSlot.addingTimeInterval(weekdayAvailability[0].start), duration: slotDuration)
        ]
        guard let nextOpenSlot = try? Scheduler.shared.nextOpenSlot(startDate: dateOnWhichToExpectOpenSlot, alreadySheduled: alreadyScheduled, weekdayAvailability: weekdayAvailability, weekendAvailability: weekendAvailability, slotDuration: slotDuration) else {
            assertionFailure("did not find correct open slot")
            return
        }
        
        assert(nextOpenSlot.duration == slotDuration, "open slot duration doesn't match provided slot duration")
        assert(calendar.compare(nextOpenSlot.start, to: dateOnWhichToExpectOpenSlot, toGranularity: .day) == .orderedSame, "open slot is not on the correct date")
        assert(calendar.compare(nextOpenSlot.start, to: alreadyScheduled[0].end, toGranularity: .minute) == .orderedSame, "open slot does not fall right after first already scheduled block")
    }
    
    func testNextOpenSlotWeekend() {
        // start on next monday after today to have consistent start date
        guard let baselineDate = calendar.nextDate(after: Date(), matching:DateComponents(weekday: 2), matchingPolicy: .strict) else {
            assertionFailure("couldn't create start date")
            return
        }
        
        guard let dateOnWhichToExpectOpenSlot = calendar.nextWeekend(startingAfter: baselineDate)?.start else {
            assertionFailure("couldn't get weekend date on which we should expect next open slot")
            return
        }
        
        assert(calendar.isDateInWeekend(dateOnWhichToExpectOpenSlot), "start date should be saturday, but is not weekend")
        assert(dateOnWhichToExpectOpenSlot.compare(Date()) == ComparisonResult.orderedDescending, "start date should be after right now, but it's before")
        
        let weekdayAvailability: [Scheduler.Slot] = []
        let weekendAvailability = [Scheduler.Slot(start: 36000, end: 79200)]
        let slotDuration = TimeInterval(1800) // 30 mins
        
        guard let startOfDateOnWhichToExpectOpenSlot = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateOnWhichToExpectOpenSlot) else {
            assertionFailure("could not set start of day for startDate")
            return
        }
        let alreadyScheduled = [
            DateInterval(start: startOfDateOnWhichToExpectOpenSlot.addingTimeInterval(weekendAvailability[0].start), duration: slotDuration)
        ]
        guard let nextOpenSlot = try? Scheduler.shared.nextOpenSlot(startDate: dateOnWhichToExpectOpenSlot, alreadySheduled: alreadyScheduled, weekdayAvailability: weekdayAvailability, weekendAvailability: weekendAvailability, slotDuration: slotDuration) else {
            assertionFailure("did not find correct open slot")
            return
        }
        
        assert(nextOpenSlot.duration == slotDuration, "open slot duration doesn't match provided slot duration")
        assert(calendar.compare(nextOpenSlot.start, to: dateOnWhichToExpectOpenSlot, toGranularity: .day) == .orderedSame, "open slot is not on the correct date")
        assert(calendar.compare(nextOpenSlot.start, to: alreadyScheduled[0].end, toGranularity: .minute) == .orderedSame, "open slot does not fall right after first already scheduled block")
    }

    func testNextOpenSlotGapBetweenAlreadyScheduledSlotsTooSmall() {
        // start on next monday after today to have consistent start date
        guard let baselineDate = calendar.nextDate(after: Date(), matching:DateComponents(weekday: 2), matchingPolicy: .strict) else {
            assertionFailure("couldn't create start date")
            return
        }
        
        guard let dateOnWhichToExpectOpenSlot = calendar.nextWeekend(startingAfter: baselineDate)?.start else {
            assertionFailure("couldn't get weekend date on which we should expect next open slot")
            return
        }
        
        assert(calendar.isDateInWeekend(dateOnWhichToExpectOpenSlot), "start date should be saturday, but is not weekend")
        assert(dateOnWhichToExpectOpenSlot.compare(Date()) == ComparisonResult.orderedDescending, "start date should be after right now, but it's before")
        
        let weekdayAvailability: [Scheduler.Slot] = []
        let weekendAvailability = [Scheduler.Slot(start: 36000, end: 79200)]
        let slotDuration = TimeInterval(1800) // 30 mins
        
        guard let startOfDateOnWhichToExpectOpenSlot = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateOnWhichToExpectOpenSlot) else {
            assertionFailure("could not set start of day for startDate")
            return
        }
        
        let alreadyScheduledSecondSlotGap = slotDuration / 2
        
        let alreadyScheduled = [
            DateInterval(start: startOfDateOnWhichToExpectOpenSlot.addingTimeInterval(weekendAvailability[0].start), duration: slotDuration),
            DateInterval(start: startOfDateOnWhichToExpectOpenSlot.addingTimeInterval(weekendAvailability[0].start + slotDuration + (alreadyScheduledSecondSlotGap)), duration: slotDuration) // leaving only small gap between first and second already scheduled blocks
        ]
        guard let nextOpenSlot = try? Scheduler.shared.nextOpenSlot(startDate: dateOnWhichToExpectOpenSlot, alreadySheduled: alreadyScheduled, weekdayAvailability: weekdayAvailability, weekendAvailability: weekendAvailability, slotDuration: slotDuration) else {
            assertionFailure("did not find correct open slot")
            return
        }
        
        assert(nextOpenSlot.duration == slotDuration, "open slot duration doesn't match provided slot duration")
        assert(calendar.compare(nextOpenSlot.start, to: dateOnWhichToExpectOpenSlot, toGranularity: .day) == .orderedSame, "open slot is not on the correct date")
        assert(calendar.compare(nextOpenSlot.start, to: alreadyScheduled[1].end.addingTimeInterval(alreadyScheduledSecondSlotGap), toGranularity: .minute) == .orderedSame, "open slot does not fall right after second already scheduled block (and added gap)")
    }
    
    func testTwoScheduledCatchups() {
        let expectation = XCTestExpectation(description: "schedule two catchups")
        
        let catchup1 = Catchup.generateRandom(name: "Testy Fail")
        let catchup2 = Catchup.generateRandom(name: "Testy Junior")
        
        Scheduler.shared.schedule([catchup1, catchup2])
            .then { (catchupsOrErrors: [Maybe<Catchup>]) in
                assert(catchupsOrErrors.compactMap { $0.error }.count == 0, "one or more catchups errored while scheduling")
                let scheduledCatchups = catchupsOrErrors.compactMap { $0.value }
                assert(scheduledCatchups.count == 2, "wrong number of catchups scheduled")
                let scheduledCatchup1 = scheduledCatchups[0]
                let scheduledCatchup2 = scheduledCatchups[1]
                XCTAssertNotNil(scheduledCatchup1.nextTouch, "catchup1 not scheduled")
                XCTAssertNotNil(scheduledCatchup2.nextTouch, "catchup2 not scheduled")
                XCTAssertFalse(self.calendar.isDate(scheduledCatchup1.nextTouch!, equalTo: scheduledCatchup2.nextTouch!, toGranularity: .minute), "catchups scheduling conflict")
                expectation.fulfill()
        }
        .catch { error in
            assertionFailure(error.localizedDescription)
        }
    
        wait(for: [expectation], timeout: 5)
    }
    
    func testPerformanceNextOpenSlotWeekday() {
        // This is an example of a performance test case.
        self.measure {
            self.testNextOpenSlotWeekday()
        }
    }

}
