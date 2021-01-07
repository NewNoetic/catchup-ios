//
//  Intervals.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

enum Intervals: String, CaseIterable, Identifiable {
    case day = "day"
    case week = "week"
    case biweek = "2 weeks"
    case month = "month"
    case threeMonths = "3 months"
    case sixMonths = "6 months"
    case year = "year"
    
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
        case .threeMonths:
            return 7257600
        case .sixMonths:
            return 14515200
        case .year:
            return 29030400
        }
    }
    
    var id: Double {
        self.value
    }
}
