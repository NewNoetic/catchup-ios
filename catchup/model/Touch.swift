//
//  Touch.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

struct Touch: Identifiable {
    var id: String {
        return "\(date.description) \(self.catchup.contact.identifier)"
    }
    
    public var date: Date
    public var catchup: Catchup
}
