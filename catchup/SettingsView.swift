//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import ContactsUI

struct SettingsView: View {
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var showContactPicker: Bool = false
    @State private var contact: CNContact? = nil
    
    var body: some View {
        List {
            Section(header: Text("Development")) {
                Button("Clear all catchups") {
                    do {
                        try Database.shared.deleteAll()
                    } catch {
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
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
                Button("Create test catchup (5s). First tap, select contact. Second tap create catchup.") {
                    if let contact = self.contact {
                        let catchup = Catchup.generateRandom(contact: contact, interval: Intervals.week.value(), nextTouch: Date(timeIntervalSinceNow: 5), nextNotification: nil)
                        Notifications.shared.schedule(catchup: catchup)
                            .then { scheduledCatchup in
                                try Database.shared.upsert(catchup: scheduledCatchup)
                        }
                        .catch { error in
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                    } else {
                        self.showContactPicker = true
                    }
                }
                .sheet(isPresented: $showContactPicker) {
                    ContactPickerViewController() { contact in
                        self.showContactPicker = false
                        self.contact = contact
                    }
                }
            }
            Section(header: Text("Danger ⚠️")) {
                Button("Drop catchups table") {
                    do {
                        try Database.shared.dropCatchupsTable()
                    } catch {
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }
        }
        .navigationBarTitle("Settings")
        .alert(isPresented: $showAlert) { () -> Alert in
            Alert(title: Text("Something happened"), message: Text(self.alertMessage))
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
