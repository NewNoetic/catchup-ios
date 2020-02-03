//
//  Settings.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
            List {
                Section {
                    Button("Drop catchups table") {
                        Database.shared.drop(tableName: "catchups")
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
