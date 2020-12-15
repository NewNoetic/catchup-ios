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
    public static var accentColor = Color(red: 1, green: 91.0/255.0, blue: 91.0/255.0)
    
    var body: some View {
        switch self.state.startView {
        case .intro1:
            return AnyView(IntroView())
                .accentColor(MainView.accentColor)
        case .catchups:
            return AnyView(ContentView().environmentObject(Upcoming()))
                .accentColor(MainView.accentColor)
        case let .text(recipients):
            return AnyView(MessageComposeView(recipients: recipients))
                .accentColor(MainView.accentColor)
        case let .email(recipients):
            return AnyView(MailComposeView(recipients: recipients))
                .accentColor(MainView.accentColor)
        }
    }
}

extension MainView {
    enum StartView {
        case intro1
        case catchups
        case text(recipients: [String])
        case email(recipients: [String])
    }
}
