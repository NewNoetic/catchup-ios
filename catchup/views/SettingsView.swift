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
    @EnvironmentObject var upcoming: Upcoming
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var showNewCatchupView: Bool = false
    @State private var catchup: Catchup? = nil
    
    @State private var weekdayTimeslotStart = 0.0
    @State private var weekdayTimeslotEnd = 1.0
    
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section() {
                    VStack(alignment: .leading) {
                        Text("Weekday time slots")
                        DoubleSlider(minimumState: self.$weekdayTimeslotStart, maximumState: self.$weekdayTimeslotEnd, width: Double(geometry.size.width))
                    }
//                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                #if DEBUG
                Section(header: Text("Development")) {
                    Button("Clear all catchups") {
                        do {
                            try Database.shared.deleteAll()
                        } catch {
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                        self.upcoming.update()
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
                        if var catchup = self.catchup {
                            catchup.nextTouch = Date(timeIntervalSinceNow: 5)
                            catchup.nextNotification = nil
                            Notifications.shared.schedule(catchup: catchup)
                                .then { scheduledCatchup in
                                    try Database.shared.upsert(catchup: scheduledCatchup)
                            }
                            .catch { error in
                                self.alertMessage = error.localizedDescription
                                self.showAlert = true
                            }
                        } else {
                            self.showNewCatchupView = true
                        }
                    }
                    .sheet(isPresented: self.$showNewCatchupView) {
                        NewCatchupView() { catchup in
                            self.catchup = catchup
                            self.showNewCatchupView = false
                        }
                    }
                    Button("Show debug list") {
                        if (self.upcoming.display == .debug) {
                            self.upcoming.display = .standard
                        } else {
                            self.upcoming.display = .debug
                        }
                    }
                    Button("⚠️ Drop catchups table") {
                        do {
                            try Database.shared.dropCatchupsTable()
                        } catch {
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                    }
                }
                #endif
            }
            .navigationBarTitle("Settings")
            .alert(isPresented: self.$showAlert) { () -> Alert in
                Alert(title: Text("Something happened"), message: Text(self.alertMessage))
            }
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
