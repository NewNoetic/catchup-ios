//
//  CatchupCell.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/13/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct CatchupCell: View {
    var up: Catchup
    
    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(up.method.capitalized) \(up.contact.displayName)")
                        .fontWeight(.bold)
                         // .capitalized produces wrong string for WhatsApp because it sets everything except first character to lowercase (https://developer.apple.com/documentation/foundation/nsstring/1416784-capitalized)
                    Spacer()
                    if let interval = Formatter.dateComponentsFormatter().string(from: up.interval) {
                        Text("Every \(interval)")
                            .foregroundColor(.gray)
                            .minimumScaleFactor(0.5)
                    }
                }
                if let nextTouch = up.nextTouch {
                    Text("Next \(Formatter.relativeDateFormatter().localizedString(for: nextTouch, relativeTo: Date())), \(Formatter.timeFormatter().string(from: nextTouch))")
                        .fontWeight(.regular)
                }
            }
            .padding(.vertical)
            .listRowInsets(.none)
    }
}

struct CatchupCell_Previews: PreviewProvider {
    static var previews: some View {
        CatchupCell(up: Catchup.generateRandom(name: "Anna Haro", interval: Intervals.week.value, nextTouch: Date().addingTimeInterval(Intervals.day.value), nextNotification: "asdf")).frame(width: 300, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
    }
}
