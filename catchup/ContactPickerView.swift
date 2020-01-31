//
//  ContactPickerView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactPickerView: View {
    @State private var contact: CNContact?
    @State private var showingContactPicker = false

    var body: some View {
        VStack {
            Text(self.contact?.givenName ?? "No contact selected")

            Button("Select Contact") {
               self.showingContactPicker = true
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ImagePicker()
        }
    }
}

struct ContactPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ContactPickerView()
    }
}
