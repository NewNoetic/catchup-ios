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
    
    var durationCases: [Intervals] = Intervals.allCases
    var methodCases: [ContactMethod] = ContactMethod.allCases
    @State private var contact: CNContact?
    @State private var durationIndex: Int = 2
    @State private var methodIndex: Int = 0
    @State private var showingContactPicker = false
    @State private var showingDurationPicker = false
    
    init(done: @escaping DoneSignature) {
        self.done = done
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 25)
                Text("Catch up with").font(.subheadline)
                Text(self.contact?.displayName ?? "").font(.largeTitle)
                Form {
                    Section {
                        Picker("How often?", selection: $durationIndex) {
                            ForEach(0 ..< durationCases.count ) { index in
                                Text("every \(self.durationCases[index].display)")
                                    .tag(index)
                            }
                            
                        }.accessibility(identifier: "duration")
                        Picker("Method?", selection: $methodIndex) {
                            ForEach(0 ..< methodCases.count ) { index in
                                Text(self.methodCases[index].display)
                                    .tag(index)
                            }
                        }.accessibility(identifier: "method")
                    }
                }
                VStack(alignment: .trailing, spacing: 20) {
                    Button("Create Ketchup") {
                        guard let contact = self.contact else { return }
                        self.done(Catchup(contact: contact, interval: self.durationCases[self.durationIndex].value, method: self.methodCases[self.methodIndex]))
                    }.accessibility(identifier: "create")
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerViewController() { contact in
                    self.showingContactPicker = false
                    self.contact = contact
                }
            }
        }
        .onAppear {
            self.showingContactPicker = true
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
