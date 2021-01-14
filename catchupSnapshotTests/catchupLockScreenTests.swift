//
//  catchupLockScreenTests.swift
//  catchupSnapshotTests
//
//  Created by SG on 1/14/21.
//  Copyright © 2021 newnoetic. All rights reserved.
//

import XCTest

class catchupLockScreenTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("--resetData")
        app.launchArguments.append("--disableIntro")
        app.launchArguments.append("--showTaps")
        app.launchArguments.append("-testing")
        app.launchArguments.append("-debug")
        addUIInterruptionMonitor(withDescription: "allow notification alert") { alert in
            if alert.label.lowercased().contains("would like to send you notifications") {
                alert.buttons["Allow"].tap()
                return true
            }
            
            return false
        }
        setupSnapshot(app)
        app.activate()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLockscreenNotification() throws {
        
        waitTap(on: app.buttons["settings"])

        let tablesQuery = app.tables
        waitTap(on: tablesQuery/*@START_MENU_TOKEN@*/.buttons["Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup."]/*[[".cells[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"].buttons[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"]",".buttons[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/)
        
        waitTap(on: app.tables.cells["Anna Haro"])
        waitTap(on: app.buttons["create"])

        waitTap(on:  tablesQuery/*@START_MENU_TOKEN@*/.buttons["Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup."]/*[[".cells[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"].buttons[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"]",".buttons[\"Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/)
        
        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        
        snapshot("04_lockscreen_notification")
    }

}
