//
//  ContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Contacts

struct ContentView: View {
    @EnvironmentObject var upcoming: Upcoming
    @State private var errorAlert = false
    @State private var showNewCatchup = false
    
    static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        let nav = NavigationView {
            VStack {
                List {
                    Section(header: Text("upcoming")) {
                        ForEach(upcoming.catchups) { up -> Text in
                            guard let nt = up.nextTouch else { return Text("\(up.contact.displayName)") }
                            return Text("\(up.contact.displayName) @ \(ContentView.dateFormatter().string(from: nt))")
                        }
                    }
                }
                Spacer()
                Button("New CatchUp") {
                    self.showNewCatchup.toggle()
                }
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
                            self.errorAlert = true
                        }
                    }
                }
                .alert(isPresented: $errorAlert) {
                    Alert(title: Text("Could not create new CatchUp"))
                }
                Spacer()
            }
            .navigationBarTitle("CatchUp")
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear").imageScale(.medium)
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
