//
//  NotificationsTests.swift
//  catchupTests
//
//  Created by Sidhant Gandhi on 2/6/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest

class NotificationsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScheduleNotification() {
        let catchup = Catchup.generateRandom(name: "Testesha Testerson")
        // TODO: Notifications.shared.schedule(catchup: catchup)
    }
}
