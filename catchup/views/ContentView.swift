//
//  ContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Contacts

extension Text {
    static func +=(lhs: inout Text, rhs: Text) {
        lhs = lhs + rhs
    }
}

struct ContentView: View {
    @EnvironmentObject var upcoming: Upcoming
    @State private var errorAlert = false
    @State private var errorMessage = ""
    @State private var showNewCatchup = false
    
    static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .none
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
                    Section(header: Text("upcoming")) {
                        ForEach(upcoming.catchups) { up -> Text in
                            var finalText = Text("\(up.method.display.capitalized) \(up.contact.displayName)") // .capitalized produces wrong string for WhatsApp because it sets everything except first character to lowercase (https://developer.apple.com/documentation/foundation/nsstring/1416784-capitalized)
                                .fontWeight(.bold)
                            if let nextTouch = up.nextTouch {
                                finalText += Text(" \(Self.relativeDateFormatter().localizedString(for: nextTouch, relativeTo: Date())), \(Self.dateFormatter().string(from: nextTouch))")
                                    .fontWeight(.regular)
                            }
                            if let interval = Self.dateComponentsFormatter().string(from: up.interval) {
                                finalText += Text("\nEvery \(interval)").foregroundColor(.gray)
                            }
                            return finalText
                        }
                        .onDelete(perform: upcoming.remove(at:))
                    }
                }
                Spacer()
                Button("New CatchUp") {
                    self.showNewCatchup.toggle()
                }.accessibility(identifier: "new catchup")
                .sheet(isPresented: $showNewCatchup) {
                    NewCatchupView() { catchup in
                        self.showNewCatchup = false
                        guard let catchup = catchup else { return }
                        Scheduler.shared.schedule([catchup])
                            .then { scheduledOrError in
                                try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                                scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
                                
                                self.upcoming.update()
                        }
                        .catch { error in
                            self.errorMessage = error.localizedDescription
                            self.errorAlert = true
                        }
                    }
                }
                .alert(isPresented: $errorAlert) {
                    Alert(title: Text(self.errorMessage))
                }
                Spacer()
            }
            .navigationBarTitle("CatchUp")
            .navigationBarItems(
                leading: Button(action: {
                    self.upcoming.update()
                }) {
                    Image(systemName: "arrow.clockwise").imageScale(.large)
                },
                trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear").imageScale(.large)
                }
            )
        }
        .onAppear {
            self.upcoming.update()
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
