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
import Introspect

extension Text {
    static func +=(lhs: inout Text, rhs: Text) {
        lhs = lhs + rhs
    }
}

struct ContentView: View {
    @EnvironmentObject var upcoming: Upcoming
    @ObservedObject var settings = AppSettings()

    @State private var errorAlert = false
    @State private var notificationsErrorAlert = false
    @State private var catchupTapAlert = false
    @State private var alertMessage = ""
    @State private var showNewCatchup = false
    @State private var showSettings = false
    
    var body: some View {
        let nav = NavigationView {
            VStack {
                self.upcoming.catchups.count > 0 ?
                    AnyView(Group {
                        List {
                            ForEach(upcoming.catchups) { up in
                                Button(action: {
                                    self.alertMessage = "Ketchup will send you a notification when it's time to catch up with \(up.contact.displayName)"
                                    self.catchupTapAlert = true
                                }) {
                                    CatchupCell(up: up)
                                }
                                .alert(isPresented: $catchupTapAlert) {
                                    Alert(title: Text(self.alertMessage), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("\(up.method.capitalized) now"), action: {
                                        Analytics.logEvent(AnalyticsEvent.CatchupNowTapped.rawValue, parameters: [AnalyticsParameter.CatchupMethod.rawValue: up.method.rawValue])
                                        up.perform()
                                    }))
                                }
                            }
                            .onDelete { (offset) in
                                Analytics.logEvent(AnalyticsEvent.CatchupDeleteSwipe.rawValue, parameters: [:])
                                self.upcoming.remove(at: offset)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }) : AnyView(
                        EmptyUpcomingView()
                    )
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
                        guard (0..<CatchupLimit ~= Database.shared.catchupsCount()) else {
                            Analytics.logEvent(AnalyticsEvent.MaxCatchupsReached.rawValue, parameters: [:])
                            self.alertMessage = "You can only create a maximum of \(CatchupLimit) Ketchups due to iOS notification limits."
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
                    .shiny()
                    .accessibility(identifier: "new catchup")
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
                                    self.alertMessage = {
                                        switch (error) {
                                        case is NotificationsError:
                                            defer { self.notificationsErrorAlert = true }
                                            return "Can't create Ketchup. You must enable notifications for Ketchup to work."
                                        default:
                                            defer { self.errorAlert = true }
                                            return "There was an error creating the Ketchup."
                                        }
                                    }()
                                    
                                }
                        }
                    }
                    .alert(isPresented: $notificationsErrorAlert) {
                        Alert(title: Text(self.alertMessage), primaryButton: .default(Text("Open Settings"), action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }), secondaryButton: .cancel())
                    }
                    Button(action: {
                        Analytics.logEvent(AnalyticsEvent.SettingsTapped.rawValue, parameters: [:])
                        self.showSettings.toggle()
                    }) {
                        Image(systemName: "gear").imageScale(.large)
                            .padding([Edge.Set.leading], 40)
                    }
                    .accessibility(identifier: "settings")
                    .sheet(isPresented: $showSettings) {
                        SettingsView().environmentObject(self.upcoming)
                            .accentColor(MainView.accentColor)
                    }
                }
                Spacer()
            }
            .alert(isPresented: $errorAlert) { Alert(title: Text(self.alertMessage)) }
            .navigationBarTitle("Ketchup")
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
        let upcoming = Upcoming(catchups: [Catchup.generateRandom(name: "Anna Haro"), Catchup.generateRandom(name: "Jon Appleseed")])
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(upcoming)
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(Upcoming(catchups: []))
        }
    }
}
