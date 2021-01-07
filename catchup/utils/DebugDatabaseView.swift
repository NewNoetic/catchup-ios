//
//  DebugDatabaseView.swift
//  catchup
//
//  Created by SG on 1/6/21.
//  Copyright © 2021 newnoetic. All rights reserved.
//

import SwiftUI

struct DebugDatabaseView: View {    
    var body: some View {
        guard let catchups = try? Database.shared.allCatchups() else { return AnyView(Text("Could not load catchups")) }
        return AnyView(VStack {
            Text("Total: \(catchups.count)")
            List {
                ForEach(catchups, id: \.id) { c in
                    VStack(alignment: .leading) {
                        Text("name \(c.contact.displayName)").font(.headline)
                        Text("phone number: \(c.phoneNumber ?? "")")
                        Text("email: \(c.email ?? "")")
                        Text("interval: \(c.interval)")
                        Text("method: \(c.method.rawValue)")
                        Text("next touch: \(c.nextTouch?.debugDescription ?? "none")")
                        Text("next notification: \(c.nextNotification == nil ? "none" : "exists")")
                    }
                }
            }
        }
        .navigationBarTitle(Text("Raw DB catchups table"), displayMode: .inline))
    }
}

struct DebugDatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        DebugDatabaseView()
    }
}
