//
//  Clamp.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/22/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
