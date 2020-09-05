//
//  ContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Contacts
import FirebaseAnalytics

extension Text {
    static func +=(lhs: inout Text, rhs: Text) {
        lhs = lhs + rhs
    }
}

struct ContentView: View {
    @EnvironmentObject var upcoming: Upcoming
    @ObservedObject var settings = Settings()

    @State private var errorAlert = false
    @State private var errorMessage = ""
    @State private var showNewCatchup = false
    @State private var showSettings = false
    
    static var timeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    static var relativeDateFormatter = { () -> RelativeDateTimeFormatter in
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.formattingContext = .middleOfSentence
        return formatter
    }
    
    static var dateComponentsFormatter = { () -> DateComponentsFormatter in
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.allowsFractionalUnits = false
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .full
        return formatter
    }
    
    var body: some View {
        let nav = NavigationView {
            VStack {
                List {
                    Section(header: Text("Upcoming (\(upcoming.catchups.count))")) {
                        ForEach(upcoming.catchups) { up -> Text in
                            switch self.upcoming.display {
                            case .standard:
                                var finalText = Text("\(up.method.capitalized) \(up.contact.displayName)") // .capitalized produces wrong string for WhatsApp because it sets everything except first character to lowercase (https://developer.apple.com/documentation/foundation/nsstring/1416784-capitalized)
                                    .fontWeight(.bold)
                                if let nextTouch = up.nextTouch {
                                    finalText += Text(" \(Self.relativeDateFormatter().localizedString(for: nextTouch, relativeTo: Date())), \(Self.timeFormatter().string(from: nextTouch))")
                                        .fontWeight(.regular)
                                }
                                if let interval = Self.dateComponentsFormatter().string(from: up.interval) {
                                    finalText += Text("\nEvery \(interval)").foregroundColor(.gray)
                                }
                                return finalText
                            case .debug:
                                return Text("name: \(up.contact.displayName)\ninterval: \(up.interval)\nmethod: \(up.method.rawValue)\nnextTouch: \(Self.dateFormatter().string(from: up.nextTouch!))\nnextNotification: \(up.nextNotification?.description ?? "x")")
                            }
                        }
                        .onDelete { (offset) in
                            Analytics.logEvent(AnalyticsEvent.CatchupDeleteSwipe.rawValue, parameters: [:])
                            self.upcoming.remove(at: offset)
                        }
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        Analytics.logEvent(AnalyticsEvent.UpdateTapped.rawValue, parameters: [AnalyticsParameter.CatchupsCount.rawValue: self.upcoming.catchups.count])
                        self.upcoming.update()
                    }) {
                        Image(systemName: "arrow.clockwise").imageScale(.large)
                            .padding([Edge.Set.trailing], 40)
                    }
                    Button(action: {
                        Analytics.logEvent(AnalyticsEvent.NewCatchupTapped.rawValue, parameters: [AnalyticsParameter.CatchupsCount.rawValue: self.upcoming.catchups.count])
                        guard (0..<60 ~= Database.shared.catchupsCount()) else {
                            Analytics.logEvent(AnalyticsEvent.MaxCatchupsReached.rawValue, parameters: [:])
                            self.errorMessage = "You can only create a maximum of 60 Ketchups due to iOS notification limits."
                            self.errorAlert = true
                            return
                        }
                        self.showNewCatchup.toggle()
                    }) {
                        Text("New Ketchup")
                            .padding([Edge.Set.leading, Edge.Set.trailing], 30)
                            .padding([Edge.Set.top, Edge.Set.bottom])
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .cornerRadius(12)
                    }
                    .accessibility(identifier: "new catchup")
                    Button(action: {
                        Analytics.logEvent(AnalyticsEvent.SettingsTapped.rawValue, parameters: [:])
                        self.showSettings.toggle()
                    }) {
                        Image(systemName: "gear").imageScale(.large)
                            .padding([Edge.Set.leading], 40)
                    }
                    .accessibility(identifier: "settings")
                }
                Spacer()
            }
            .sheet(isPresented: $showNewCatchup) {
                NewCatchupView() { catchup in
                    self.showNewCatchup = false
                    guard let catchup = catchup else { return }
                    
                    UserNotificationsAsync.authenticate()
                        .then { Scheduler.shared.schedule([catchup]) }
                        .then { scheduledOrError in
                            try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                            scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
                            if let scheduledCatchup = scheduledOrError.first?.value {
                                guard let date = scheduledCatchup.nextTouch else { return }
                                Analytics.logEvent(AnalyticsEvent.NewCatchupCreated.rawValue, parameters: [
                                    AnalyticsParameter.CatchupInterval.rawValue: scheduledCatchup.interval,
                                    AnalyticsParameter.CatchupMethod.rawValue: scheduledCatchup.method.rawValue,
                                    AnalyticsParameter.CatchupDate.rawValue: date.debugDescription,
                                    AnalyticsParameter.Timezone.rawValue: TimeZone.current.identifier,
                                    AnalyticsParameter.SettingsDuration.rawValue: self.settings.timeslotDuration
                                ])
                            }
                            self.upcoming.update()
                    }
                    .catch { error in
                        self.errorMessage = {
                            switch (error) {
                            case is NotificationsError:
                                return "You must enable notifications for Ketchup to work."
                            default:
                                return "There was an error creating the Ketchup."
                            }
                        }()
                        self.errorAlert = true
                    }
                }
            }
            .alert(isPresented: $errorAlert) {
                Alert(title: Text(self.errorMessage), primaryButton: .default(Text("Open Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }), secondaryButton: .cancel())
            }
            .navigationBarTitle("🥫 Ketchup")
            
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(self.upcoming)
                .accentColor(MainView.accentColor)
        }
            
        .onAppear {
            self.upcoming.update()
            // after delay to let catchups load from database
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                Analytics.setUserProperty("\(self.upcoming.catchups.count)", forName: AnalyticsParameter.CatchupsCount.rawValue)
            }
            Analytics.setUserProperty(self.settings.weekdayTimeslots().reduce(into: "", { (result, slot) in
                result += "s:\(slot.start)|e:\(slot.end),"
            }), forName: AnalyticsParameter.SettingsWeekdayTimeslots.rawValue)
            Analytics.setUserProperty(self.settings.weekendTimeslots().reduce(into: "", { (result, slot) in
                result += "s:\(slot.start)|e:\(slot.end),"
            }), forName: AnalyticsParameter.SettingsWeekendTimeslots.rawValue)
            Analytics.setUserProperty("\(self.settings.timeslotDuration)", forName: AnalyticsParameter.SettingsDuration.rawValue)
        }
        
        return nav
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Upcoming())
    }
}
