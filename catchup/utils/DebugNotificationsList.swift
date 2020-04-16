//
//  DebugNotificationsList.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/15/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import UserNotifications

struct DebugNotificationsList: View {
    @State private var notifications: [UNNotificationRequest] = []
    
    func loadNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            self.notifications = requests
        }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(notifications, id: \.identifier) { note in
                    VStack {
                        Text("ID: \(note.identifier)")
                        Text("Date: \((note.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()?.description ?? "")")
                    }
                }
            }
            .onAppear {
                self.loadNotifications()
            }
            Button(action: {
                self.loadNotifications()
            }) { Text("Reload") }
        }
        .navigationBarTitle(Text("Scheduled system notifications"), displayMode: .inline)
    }
}

struct DebugNotificationsList_Previews: PreviewProvider {
    static var previews: some View {
        DebugNotificationsList()
    }
}
