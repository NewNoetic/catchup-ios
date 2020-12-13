//
//  Formatter.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/13/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

struct Formatter {
    static var timeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    static var relativeDateFormatter = { () -> RelativeDateTimeFormatter in
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.formattingContext = .middleOfSentence
        return formatter
    }
    
    static var dateComponentsFormatter = { () -> DateComponentsFormatter in
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.allowsFractionalUnits = false
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .full
        return formatter
    }
}
