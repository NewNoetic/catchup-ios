//
//  Intervals.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

enum Intervals: String, CaseIterable, Identifiable {
    case day
    case week
    case biweek
    case month
    
    var display: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .biweek:
            return "2 weeks"
        case .month:
            return "month"
        }
    }
    
    var value: TimeInterval {
        switch self {
        case .day:
            return 86400
        case .week:
            return 604800
        case .biweek:
            return 1209600
        case .month:
            return 2419200
        }
    }
    
    var id: Double {
        self.value
    }
}
