//
//  ContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var upcoming: Upcoming
    @State private var errorAlert = false
    @State private var showNewCatchup = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List {
                    Section(header: Text("upcoming")) {
                        ForEach(upcoming.catchups) { up in
                            Text("\(up.contact.givenName) \(up.contact.familyName)")
                        }
                    }
                }
                Spacer()
                    Button("New CatchUp") {
                       self.showNewCatchup.toggle()
                    }
//                    .sheet(isPresented: $showNewCatchup) {
//                        ContactPickerView() { contact in
//                            do {
//                                try Database.shared.upsert(catchup: Catchup(contact: contact, interval: Intervals.week.rawValue, method: .call))
//                                self.upcoming.update()
//                            } catch {
//                                self.errorAlert = true
//                            }
//                        }
//                    }
                    .alert(isPresented: $errorAlert) {
                        Alert(title: Text("Could not create new CatchUp"))
                    }
                Spacer()
            }
            .navigationBarTitle("CatchUp")
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(Upcoming())
    }
}
