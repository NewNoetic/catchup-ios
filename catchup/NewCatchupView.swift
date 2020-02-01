//
//  ContactPickerView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import Contacts

struct NewCatchupView: View {
    typealias DoneSignature = (Catchup?) -> Void
    var done: DoneSignature
    @State private var contact: CNContact?
    @State private var duration: TimeInterval?
    @State private var showingContactPicker = true // open contact picker immediately

    init(done: @escaping DoneSignature) {
        self.done = done
    }
    
    var body: some View {
        VStack {
            Text(self.contact?.givenName ?? "No contact selected")

            Button("Select Contact") {
               self.showingContactPicker = true
            }
            
            Button("Create Catchup") {
                guard let contact = self.contact else { return }
                self.done(Catchup(contact: contact, interval: Intervals.week.rawValue, method: .call))
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerViewController() { contact in
                self.showingContactPicker = false
                self.contact = contact
            }
        }
    }
}

struct ContactPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NewCatchupView() { catchup in
            //
        }
    }
}
