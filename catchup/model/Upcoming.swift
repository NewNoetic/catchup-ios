//
//  Upcoming.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Combine

final class Upcoming: ObservableObject {
    @Published var catchups: [Catchup] = []
    
    func update() {
        guard let c = try? Database.shared.allCatchups()
            else { return }
        self.catchups = c
    }
}
