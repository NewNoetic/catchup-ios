//
//  AppState.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/17/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation

class AppState: ObservableObject {
    @Published var startView: StartView = .catchups
    
    public static var shared = AppState()
}
