//
//  maxCatchupsTest.swift
//  catchupUITests
//
//  Created by Sidhant Gandhi on 6/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest

class maxCatchupsTest: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("--disableAnimation")
        app.launchArguments.append("--resetData")
        addUIInterruptionMonitor(withDescription: "allow notification alert") { alert in
            let button = alert.buttons.element(boundBy: 1)
            if button.exists {
                button.tap()
            }
            return true
        }
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMaxCatchups() {
        for n in 0...61 {
            print("NEW CATCHUP \(n)")
            waitTap(on: app/*@START_MENU_TOKEN@*/.buttons["new catchup"]/*[[".buttons[\"New CatchUp\"]",".buttons[\"new catchup\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/)
            if (n >= 60) {
                XCTAssertFalse(app.buttons["create"].exists)
                XCTAssertTrue(app.staticTexts["You can only create a maximum of 60 Ketchups due to iOS notification limits."].waitForExistence(timeout: 3000))
                continue
            } else {
                XCTAssertTrue(app.buttons["create"].exists)
            }
            waitTap(on: app.tables["ContactsListView"].cells.element(boundBy: n))
            waitTap(on: app.buttons["create"])
        }
    }
}
