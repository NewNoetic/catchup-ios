//
//  StartView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/17/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

enum StartView {
    case intro1
    case catchups
    case text(recipients: [String])
    case email(recipients: [String])
}

enum EmailApp: String {
    case iOSMail
    case Gmail
}
