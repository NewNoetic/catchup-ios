//
//  DoubleSlider.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/22/20 with example from https://gist.github.com/mathonsunday/22f28cf15c3d4a866d7030bf7c744dd0
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct DoubleSlider : View {
    @Binding var minimumState: Double
    @Binding var maximumState: Double
    
    var width: Double
    var handleSize: CGFloat = 24.0
    
    init(minimumState: Binding<Double>, maximumState: Binding<Double>, width: Double) {
        self._minimumState = minimumState
        self._maximumState = maximumState
        self.width = width
    }
    
    var body: some View {
        let leadingHandleGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                print(value)
//                guard value.location.x >= 0 else {
//                    return
//                }
                let adjustedLocation = value.location.x
                self.minimumState = (Double(adjustedLocation) / self.width).clamped(to: 0...1)
                print(self.minimumState)
        }
        let trailingHandleGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                print(value)
//                guard value.location.x <= 0 else {
//                    return
//                }
                let adjustedLocation = value.location.x
                self.maximumState = (1 - (Double(abs(adjustedLocation)) / self.width).clamped(to: 0...1))
                print(self.maximumState)
        }
        return (
            HStack(spacing: -24) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24, alignment: .center)
                    .offset(x: CGFloat(self.minimumState * self.width), y: 0)
                    .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 3.0)
                    .gesture(leadingHandleGesture)
                    .zIndex(1)
                Capsule()
                    .fill(Color(UIColor.systemGray))
                    .frame(maxWidth: CGFloat(self.width), minHeight: 4, idealHeight: 3, maxHeight: 3, alignment: .center)
                    .zIndex(0)
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24, alignment: .center)
                    .offset(x: CGFloat((1.0 - self.maximumState) * -self.width), y: 0)
                    .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 3.0)
                    .gesture(trailingHandleGesture)
                    .zIndex(1)
            }
        )
    }
}

struct DoubleSlider_Previews : PreviewProvider {
    @State static var min = 0.0
    @State static var max = 1.0
    static var previews: some View {
        GeometryReader { geometry in
            DoubleSlider(minimumState: $min, maximumState: $max, width: Double(geometry.size.width))
        }
    }
}
