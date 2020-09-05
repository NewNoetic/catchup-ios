//
//  DatabaseTests.swift
//  catchupTests
//
//  Created by Sidhant Gandhi on 9/5/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest

class DatabaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllCatchups() throws {
        let catchups = try Database.shared.allCatchups()
        catchups.forEach { (catchup) in
            print(catchup)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
