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
        PageViewData(title: "Welcome to Ketchup", subtitle: "We hope it helps you keep in touch with people you care about.", color: Color.white, background: MainView.accentColor, emoji: "👋"),
        PageViewData(title: "Create some Ketchups", subtitle: "", color: Color.white, background: Color.green, emoji: "👯")
    ]
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            PageContainerView(pages: pages)
            Button(action: {
                SceneDelegate.appState.startView = .catchups
            }) {
                Text("Done")
                    .padding([Edge.Set.leading, Edge.Set.trailing], 30)
                    .padding([Edge.Set.top, Edge.Set.bottom])
                    .background(Color.secondary)
                    .foregroundColor(Color.white)
                    .cornerRadius(12)
            } 
            .accessibility(identifier: "intro done")
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
