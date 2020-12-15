//
//  PageContentView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/11/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct PageContainerView: View {
    var pages: [PageViewData]
    
    @State private var index: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            SwipeView(pages: self.pages, index: self.$index)
            HStack(spacing: 8) {
                ForEach(0..<self.pages.count) { index in
                    CircleIndicator(isSelected: Binding<Bool>(get: { self.index == index }, set: { _ in })) {
                        withAnimation {
                            self.index = index
                        }
                    }
                }
            }
        }
    }
}

struct PageContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PageContainerView(pages: [
            PageViewData(title: "Welcome to Ketchup", subtitle: "We hope it helps you keep in touch with people you care about.", color: Color.white, background: MainView.accentColor, emoji: "👋"),
            PageViewData(title: "Create some Ketchups", subtitle: "", color: Color.white, background: Color.green, emoji: "👯")
        ])
    }
}
