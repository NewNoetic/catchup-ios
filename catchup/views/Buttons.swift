//
//  BlockButton.swift
//  numbers
//
//  Created by Sidhant Gandhi on 6/20/20.
//  Copyright © 2020 NewNoetic, Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct BlockButton: ButtonStyle {
    var width: CGFloat = .infinity
    var background: Color = Color.accentColor
    var foreground: Color = Color.white
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: self.width)
            .padding()
            .background(self.background)
            .foregroundColor(self.foreground)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .animation(.spring())
    }
}

struct BlockButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("hello") {
            
        }
        .buttonStyle(BlockButton())
    }
}

struct CircleButton: ButtonStyle {
    var width: CGFloat = 75
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: self.width, height: self.width)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(Color.white)
            .cornerRadius(width)
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .animation(.spring())
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("hello") {
            
        }
        .buttonStyle(CircleButton())
    }
}
