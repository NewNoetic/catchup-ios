//
//  Slot.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

/// Represents a time slot in a day
struct Slot {
    /// Seconds since start of day
    var start: TimeInterval
    
    /// Seconds since start of day
    var end: TimeInterval
}
