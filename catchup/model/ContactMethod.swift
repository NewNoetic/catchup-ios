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
    case whatsapp = "WhatsApp"
    case facetime = "FaceTime"
    
    var id: String {
        self.rawValue
    }
    
    var capitalized: String {
        switch self {
        case .whatsapp: return "WhatsApp"
        case .facetime: return "FaceTime"
        default: return self.rawValue.capitalized
        }
    }
}

