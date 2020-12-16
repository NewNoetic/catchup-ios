//
//  IntroView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/15/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct IntroView: View {
    var pages = [
        PageViewData(title: "Welcome to Ketchup", subtitle: "Ketchup nudges you at the right time to reach out to family, friends and colleagues.", color: Color.white, background: MainView.accentColor, emoji: "👋"),
        PageViewData(title: "Choose a contact", subtitle: "And set how often you want to catch up with them. Ketchup automatically schedules a notification to remind you at the right time.", color: Color.white, background: Color.blue, emoji: "👯"),
        PageViewData(title: "If you miss a Ketchup, it's okay", subtitle: "The notifications are recurring, so just catch them next time around.", color: Color.white, background: Color.green, emoji: "🔁")
    ]
    
    @State var pageIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            PageContainerView(pages: pages, index: $pageIndex)
            if (self.pageIndex + 1 >= pages.count) {
                Button(action: {
                    SceneDelegate.appState.startView = .catchups
                }) {
                    Text("Done")
                }
                .buttonStyle(BlockButton(background: .white, foreground: .accentColor))
                .padding()
                .accessibility(identifier: "intro done")
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
