//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import ContactsUI

let calendar = Calendar(identifier: .gregorian)

struct SettingsView: View {
    
    @EnvironmentObject var upcoming: Upcoming
    @ObservedObject var settings = Settings()
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var showNewCatchupView: Bool = false
    @State private var catchup: Catchup? = nil

//    @State private var settingsTimeslotDuration: TimeInterval = UserDefaults.standard.value(forKey: "settings.timeslotDuration") as? TimeInterval ?? 1800 {
//        didSet {
//            UserDefaults.standard.setValue(settingsTimeslotDuration, forKey: "settings.timeslotDuration")
//        }
//    }
//
//    @State private var settingsWeekdayTimeslotStartIndex: Int = UserDefaults.standard.value(forKey: "settings.weekdayTimelslotStartIndex") as? Int ?? 17 {
//        didSet {
//            UserDefaults.standard.setValue(settingsWeekdayTimeslotStartIndex, forKey: "settings.weekdayTimelslotStartIndex")
//        }
//    }
    
    var timeslotOptions: [TimeInterval] = [3600, 3600*2, 3600*3, 3600*4, 3600*5, 3600*6, 3600*7, 3600*8, 3600*9, 3600*10, 3600*11, 3600*12, 3600*13, 3600*14, 3600*15, 3600*16, 3600*17, 3600*18, 3600*19, 3600*20, 3600*21, 3600*22, 3600*23]
    
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
        GeometryReader { geometry in
            Form {
                Section(header: Text("Timeslot duration")) {
                    VStack {
                        Slider(value: self.$settings.timeslotDuration, in: 900...3600, step: 300)
                        Text("\(Int(self.settings.timeslotDuration/60)) minutes")
                    }.padding()
                }
                Section(header: Text("Weekday time slots")) {
                    Picker("Start", selection: self.$settings.weekdayTimeslotStartIndex) {
                        ForEach(0 ..< self.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.timeslotOptions[index]))")
                        }
                    }
                    Picker("End", selection: self.$settings.weekdayTimeslotEndIndex) {
                        ForEach(0 ..< self.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.timeslotOptions[index]))")
                        }
                    }
                }
                Section(header: Text("Weekend time slots")) {
                    Picker("Start", selection: self.$settings.weekendTimeslotStartIndex) {
                        ForEach(0 ..< self.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.timeslotOptions[index]))")
                        }
                    }
                    Picker("End", selection: self.$settings.weekendTimeslotEndIndex) {
                        ForEach(0 ..< self.timeslotOptions.count) { index in
                            Text("\(self.timeslotToHour(timeslot: self.timeslotOptions[index]))")
                        }
                    }
                }
                Section(footer: Text("Re-schedule to use new duration and time slot settings.")) {
                    Button("Re-schedule Ketchups") {
                        let allCatchups = (try? Database.shared.allCatchups()) ?? []
                        Scheduler.shared.reschedule(allCatchups)
                        .then { scheduledOrError in
                                try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                                scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
                        }
                        .catch { error in
                            print("could not reschedule some or all catchups")
                            self.alertMessage = "Could not reschedule some or all Ketchups"
                            self.showAlert = true
                        }
                    }
                }
                #if DEBUG
                Section(header: Text("Development")) {
                    Button("Clear all Ketchups") {
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
        NavigationView {
            SettingsView()
        }
    }
}
