//
//  DebugCompareCatchupsToNotifications.swift
//  catchup
//
//  Created by SG on 1/6/21.
//  Copyright © 2021 newnoetic. All rights reserved.
//

import SwiftUI

struct DebugCompareCatchupsToNotifications: View {
    @State private var notifications: [UNNotificationRequest] = []
    
    func loadNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            self.notifications = requests
        }
    }
    
    var body: some View {
        guard let catchups = try? Database.shared.allCatchups() else { return AnyView(Text("Could not load catchups")) }
        
        let invalidCatchups = catchups.filter { c in
            // only include catchups that have a notification
            self.notifications.first { r in
                return r.identifier == c.nextNotification ?? ""
            } == nil
        }
        
        let invalidNotifications = notifications.filter { n in
            catchups.first { c in
                return c.nextNotification == n.identifier
            } == nil
        }
        
        return AnyView(VStack {
            List {
                Text("invalid catchups: \(invalidCatchups.count)").bold()
                ForEach(invalidCatchups, id: \.id) { c in
                    VStack {
//                        Text("ID: \(c.id)")
                        Text("Name: \(c.contact.displayName)")
                        Text("Date: \(c.nextTouch?.description ?? "")")
                    }
                }
                Text("invalid notifications: \(invalidNotifications.count)").bold()
                ForEach(invalidNotifications, id: \.identifier) { n in
                    VStack {
                        Text("ID: \(n.identifier)")
                        Text("Date: \((n.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()?.description ?? "")")
                    }
                }
            }
            .onAppear {
                self.loadNotifications()
            }
            Button(action: {
                self.loadNotifications()
            }) { Text("Reload") }
        }
        .navigationBarTitle(Text("Scheduled system notifications"), displayMode: .inline))
    }
}

struct DebugCompareCatchupsToNotifications_Previews: PreviewProvider {
    static var previews: some View {
        DebugCompareCatchupsToNotifications()
    }
}
