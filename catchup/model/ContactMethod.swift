//
//  ContactMethod.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

enum ContactMethod: String, CaseIterable, Identifiable {
    case call
    case text
    case email
    case whatsapp
    
    var display: String {
        switch self {
        case .whatsapp:
            return "WhatsApp"
        default:
            return self.rawValue
        }
    }
    
    var id: String {
        self.rawValue
    }
}

