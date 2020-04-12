//
//  CircleIndicator.swift
//  catchup
//
//  Created by Sidhant Gandhi on 4/11/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct CircleIndicator: View {
    @Binding var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) { Circle()
            .frame(width: 8, height: 8)
            .foregroundColor(self.isSelected ? Color(UIColor.systemGray6) : Color(UIColor.systemGray2))
        }
    }
}

struct CircleIndicator_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CircleIndicator(isSelected: .constant(true)) {
                
            }
            CircleIndicator(isSelected: .constant(false)) {
                
            }
        }
    }
}
