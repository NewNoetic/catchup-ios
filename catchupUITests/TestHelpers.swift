//
//  TestHelpers.swift
//  catchupUITests
//
//  Created by Sidhant Gandhi on 4/18/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import XCTest

typealias WaitCompletion<T> = (_ element: T) -> ()

func waitTap<T>(on element: T, for timeout: TimeInterval = 5, action: WaitCompletion<T>? = nil) where T: XCUIElement {
    XCTAssert(element.waitForExistence(timeout: timeout), "No element: \(element.elementType.rawValue)/\(element.identifier)")
    
    if let action = action {
        action(element)
    } else {
        element.tap()
    }
}
