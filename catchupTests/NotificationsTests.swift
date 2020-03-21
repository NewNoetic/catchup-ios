//
//  NotificationsTests.swift
//  catchupTests
//
//  Created by Sidhant Gandhi on 2/6/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest
import Promises
import UserNotifications

class NotificationsTests: XCTestCase {
    
    let calendar = Calendar.init(identifier: .gregorian)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func testScheduleNotification() {
        let expectation = XCTestExpectation(description: "schedule catchup notification")
        
        var catchup = Catchup.generateRandom(name: "Testy Testerson")
        let nextTouch = Date().addingTimeInterval(Intervals.day.value)
        catchup.nextTouch = nextTouch
        Notifications.shared.schedule(catchup: catchup)
            .then { scheduled in
                guard let scheduledNextTouch = scheduled.nextTouch else {
                    assertionFailure("shceduled next touch is nil")
                    return
                }
                assert(self.calendar.isDate(scheduledNextTouch, equalTo: scheduled.nextTouch!, toGranularity: .minute), "scheduled next touch not same as the original next touch")
                UNUserNotificationCenter.current().getPendingNotificationRequests { r in
                    let request = r.filter { req -> Bool in
                        req.identifier == scheduled.nextNotification
                        }[0]
                    assert(request.identifier == scheduled.nextNotification, "notification not scheduled")
                    assert(request.content.title.contains(catchup.contact.givenName), "notification doesn't contain contact name")
                    let trigger = request.trigger as! UNCalendarNotificationTrigger
                    assert(self.calendar.isDate(trigger.nextTriggerDate()!, equalTo: nextTouch, toGranularity: .minute))
                    
                    expectation.fulfill()
                }
        }
        .catch { error in
            assertionFailure("could not schedule catchup")
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
