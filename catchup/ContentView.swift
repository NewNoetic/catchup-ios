//
//  ContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var upcoming: [Touch] = [
        Touch(date: Date().addingTimeInterval(Intervals.day.rawValue), catchup: Catchup.generateRandom(name: "Ra theGreat")),
        Touch(date: Date().addingTimeInterval(Intervals.day.rawValue), catchup: Catchup.generateRandom(name: "John Appleseed"))
    ]
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List {
                    Section(header: Text("upcoming")) {
                        ForEach(upcoming) { up in
                            Text("\(up.catchup.contact.givenName) \(up.catchup.contact.familyName)")
                        }
                    }
                }
                Spacer()
                Button("New CatchUp") {
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
    }
}
