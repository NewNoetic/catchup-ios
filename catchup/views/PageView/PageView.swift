//
//  PageView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/11/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
struct PageViewData: Identifiable {
    let id = UUID().uuidString
    let title: String
    let subtitle: String
    let color: Color
    let background: Color
    let emoji: String
}

struct PageView: View {
    let viewData: PageViewData
    var body: some View {
        ZStack {
            viewData.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 36) {
                Text(viewData.emoji)
                    .font(.system(size: 100))
                    .padding(.top, 50)
                Text(viewData.title)
                    .font(Font.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text(viewData.subtitle)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(viewData.color)
        }
        
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(viewData: PageViewData(title: "Welcome to Ketchup", subtitle: "We hope it helps you keep in touch with people you care about.", color: Color.white, background: MainView.accentColor, emoji: "👋"))
    }
}
