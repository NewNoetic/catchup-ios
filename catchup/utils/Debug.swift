//
//  Debug.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/19/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

func isDebug() -> Bool {
    var debug = false
    #if DEBUG
    debug = true
    #endif
    return debug
}
