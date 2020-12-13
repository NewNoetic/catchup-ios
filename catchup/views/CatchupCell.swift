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
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color.init(white: 0.5, opacity: 0.1))
            VStack(alignment: .leading, spacing: 8) {
                Text("\(up.method.capitalized) \(up.contact.displayName)")
                    .fontWeight(.bold)
                     // .capitalized produces wrong string for WhatsApp because it sets everything except first character to lowercase (https://developer.apple.com/documentation/foundation/nsstring/1416784-capitalized)
                if let nextTouch = up.nextTouch {
                    Text("\(Formatter.relativeDateFormatter().localizedString(for: nextTouch, relativeTo: Date()).capitalized), \(Formatter.timeFormatter().string(from: nextTouch))")
                        .fontWeight(.regular)
                }
                if let interval = Formatter.dateComponentsFormatter().string(from: up.interval) {
                    Text("Every \(interval)").foregroundColor(.gray)
                }
            }
            .padding()
        }
        .listRowInsets(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
    }
}

struct CatchupCell_Previews: PreviewProvider {
    static var previews: some View {
        CatchupCell(up: Catchup.generateRandom(name: "Anna Haro", interval: Intervals.week.value, nextTouch: Date().addingTimeInterval(Intervals.day.value), nextNotification: "asdf")).frame(width: 300, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
