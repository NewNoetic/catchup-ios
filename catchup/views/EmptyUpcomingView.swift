//
//  EmptyUpcomingView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/15/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct EmptyUpcomingView: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10) {
            Spacer()
            Text("Tap here to get started")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
            Text("👇")
                .font(.system(size: 50))
                .padding(.bottom, 20)
        }
    }
}

struct EmptyUpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyUpcomingView()
    }
}
