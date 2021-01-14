//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import ContactsUI
import FirebaseAnalytics

let calendar = Calendar(identifier: .gregorian)

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var upcoming: Upcoming
    @ObservedObject var settings = AppSettings()
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var showNewCatchupView: Bool = false
    @State private var catchup: Catchup? = nil
    
    func timeslotToHour(timeslot: TimeInterval) -> String {
        guard var today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else {
            return "\(timeslot)"
        }
        today.addTimeInterval(timeslot)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: today)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ketchup duration")) {
                    VStack {
                        Slider(value: self.$settings.timeslotDuration, in: 900.0...3600.0, step: 300.0)
                        Text("\(Int(self.settings.timeslotDuration/60)) minutes")
                    }.padding()
                }
                Section(header: Text("Weekday free time")) {
                    Picker("Start", selection: self.$settings.weekdayTimeslotStartIndex) {
                        ForEach(0 ..< self.settings.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.settings.timeslotOptions[index]))")
                        }
                    }
                    Picker("End", selection: self.$settings.weekdayTimeslotEndIndex) {
                        ForEach(0 ..< self.settings.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.settings.timeslotOptions[index]))")
                        }
                    }
                }
                Section(header: Text("Weekend free time")) {
                    Picker("Start", selection: self.$settings.weekendTimeslotStartIndex) {
                        ForEach(0 ..< self.settings.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.settings.timeslotOptions[index]))")
                        }
                    }
                    Picker("End", selection: self.$settings.weekendTimeslotEndIndex) {
                        ForEach(0 ..< self.settings.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.settings.timeslotOptions[index]))")
                        }
                    }
                }
                if (CommandLine.arguments.contains("-debug")) {
                    Section(header: Text("Development")) {
                        Button("Create test local notification (5s)") {
                            let content = UNMutableNotificationContent()
                            content.title = "Test notification"
                            content.body = "This is a test notification!"
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                            let request = UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request)
                        }
                        Button("Create test Ketchup (5s). First tap, select contact. Second tap create Ketchup.") {
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
                        Toggle("Show debug list", isOn: Binding(get: {
                            self.upcoming.display == .debug
                        }, set: { newVal in
                            self.upcoming.display = newVal ? .debug : .standard
                        }))
                        NavigationLink(destination: DebugNotificationsList()) {
                            Text("View scheduled system notifications")
                        }
                        NavigationLink(destination: DebugDatabaseView()) {
                            Text("View raw database")
                        }
                        NavigationLink(destination: DebugCompareCatchupsToNotifications()) {
                            Text("Compare catchups to notifications")
                        }
                        Button("⚠️ Clear all Ketchups") {
                            do {
                                try Database.shared.deleteAll()
                            } catch {
                                self.alertMessage = error.localizedDescription
                                self.showAlert = true
                            }
                            self.upcoming.update()
                        }.accessibility(identifier: "clear catchups")
                        Button("⚠️ Clear all scheduled notifications") {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }.accessibility(identifier: "clear notifications")
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(
                leading: Button(action: {
                    Analytics.logEvent(AnalyticsEvent.SettingsCancelTapped.rawValue, parameters: [:])
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    Analytics.logEvent(AnalyticsEvent.SettingsSaveTapped.rawValue, parameters: [AnalyticsParameter.CatchupsCount.rawValue: self.upcoming.catchups.count])
                    let allCatchups = (try? Database.shared.allCatchups()) ?? []
                    Scheduler.shared.reschedule(allCatchups)
                        .then { scheduledOrError in
                            try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                            scheduledOrError.compactMap { $0.error }.forEach { captureError($0) } // TODO: grab individual errors and catchups from them if provided
                    }
                    .catch { error in
                        captureError(error, message: "could not reschedule some or all catchups")
                        self.alertMessage = "Could not reschedule some or all Ketchups"
                        self.showAlert = true
                    }
                    .always {
                        self.upcoming.update()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
            })
                .alert(isPresented: self.$showAlert) { () -> Alert in
                    Alert(title: Text("Something happened"), message: Text(self.alertMessage))
            }
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
