//
//  catchupSnapshotTests.swift
//  catchupSnapshotTests
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest

class catchupSnapshotTests: XCTestCase {
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
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    
    func testNewCatchups() {
        snapshot("main")
        let newCatchupButton = app/*@START_MENU_TOKEN@*/.buttons["new catchup"]/*[[".buttons[\"New CatchUp\"]",".buttons[\"new catchup\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let contacts: [ContactsCatchup] = [
            ContactsCatchup(name: "John Appleseed", duration: .day, method: .call),
            ContactsCatchup(name: "Kate Bell", duration: .week, method: .text),
            ContactsCatchup(name: "Anna Haro", duration: .biweek, method: .email),
            ContactsCatchup(name: "Daniel Higgins Jr.", duration: .month, method: .facetime),
        ]
        
        for (index, contact) in contacts.enumerated() {
            waitTap(on: newCatchupButton)
            waitTap(on: app.tables.cells[contact.name])
            waitTap(on: app.buttons["How often?"])
            
            if (index == 0) {
                snapshot("duration options")
            }
            
            waitTap(on: app.buttons["every \(contact.duration.rawValue)"])
            waitTap(on: app.buttons["method"])
            
            if (index == 0) {
                snapshot("method options")
            }
            
            waitTap(on: app.buttons[contact.method.rawValue])
            
            if (index == 0) {
                snapshot("new contact")
            }
            
            waitTap(on: app.buttons["create"])
        }
        
        snapshot("all contacts")
        
        waitTap(on: app.buttons["settings"])
        
        snapshot("settings")
    }
}
