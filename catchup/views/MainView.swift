//
//  MainView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import SwiftUI

struct MainView: View {
    @EnvironmentObject var state: AppState
    var accentColor = Color.orange
    
    var body: some View {
        switch self.state.startView {
        case .catchups:
            print("view catchups")
            return AnyView(ContentView().environmentObject(Upcoming()))
            .accentColor(accentColor)
        case let .text(recipients):
            print("view text")
            return AnyView(MessageComposeView(recipients: recipients))
            .accentColor(accentColor)
        case let .email(recipients):
            print("view email")
            return AnyView(MailComposeView(recipients: recipients))
            .accentColor(accentColor)
        }
    }
}

extension MainView {
    enum StartView {
        case catchups
        case text(recipients: [String])
        case email(recipients: [String])
    }
}
