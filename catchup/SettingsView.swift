//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
            List {
                Section {
                    Button("Drop catchups table") {
                        Database.shared.drop(tableName: "catchups")
                    }
                    Button("Clear all scheduled notifications") {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    Button("Create test local notification (5s)") {
                        let content = UNMutableNotificationContent()
                        content.title = "Test notification"
                        content.body = "This is a test notification!"
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        let request = UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
