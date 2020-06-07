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
    @Environment(\.presentationMode) var presentationMode

    var durationCases: [Intervals] = Intervals.allCases
    var methodCases: [ContactMethod] = ContactMethod.allCases
    @State private var contact: CNContact?
    @State private var durationIndex: Int = 2
    @State private var methodIndex: Int = 0
    @State private var showingContactPicker = ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 4, patchVersion: 0)) ? false : true
    
    init(done: @escaping DoneSignature) {
        self.done = done
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 25)
                Text("Catch up with").font(.subheadline).bold().foregroundColor(Color(UIColor.systemGray))
                Spacer(minLength: 12)
                Button(action: {
                    self.showingContactPicker = true
                }) {
                    Text(self.contact?.displayName ?? "Pick contact").font(.largeTitle).bold()
                }
                Form {
                    Section {
                        Picker("How often?", selection: $durationIndex) {
                            ForEach(0 ..< durationCases.count ) { index in
                                Text("every \(self.durationCases[index].rawValue)")
                                    .tag(index)
                            }
                        }
                        .accessibility(identifier: "duration")
                        Picker("Method?", selection: $methodIndex) {
                            ForEach(0 ..< methodCases.count ) { index in
                                Text(self.methodCases[index].rawValue)
                                    .tag(index)
                            }
                        }
                        .accessibility(identifier: "method")
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                VStack(alignment: .center, spacing: 30) {
                    Text("Ketchup will automatically schedule a time according to your settings.")
                        .foregroundColor(Color.init(UIColor.systemGray))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding()
                    Button(action: {
                        guard let contact = self.contact else {
                            self.showingContactPicker = true
                            return
                        }
                        self.done(Catchup(contact: contact, interval: self.durationCases[self.durationIndex].value, method: self.methodCases[self.methodIndex]))
                    }) {
                        Text("Create Ketchup")
                            .padding([Edge.Set.leading, Edge.Set.trailing], 30)
                            .padding([Edge.Set.top, Edge.Set.bottom])
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .cornerRadius(12)
                    }
                    .accessibility(identifier: "create")

                }
                Spacer()
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerViewController() { contact in
                    self.showingContactPicker = false
                    self.contact = contact
                }
            }
        .navigationBarItems(trailing: Button("Cancel") { self.presentationMode.wrappedValue.dismiss() })
        }
        .accentColor(MainView.accentColor)
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
