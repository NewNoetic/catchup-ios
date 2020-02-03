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
//    var durationCases: [Intervals] = [Intervals.day, Intervals.week, Intervals.month]
    @State private var contact: CNContact?
    @State private var durationIndex: Int?
    @State private var showingContactPicker = true // open contact picker immediately
    @State private var showingDurationPicker = false
    
    init(done: @escaping DoneSignature) {
        self.done = done
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 25)
                Text("Catch up with").font(.subheadline)
                Text(self.contact?.givenName ?? "").font(.largeTitle)
                Form {
                    Section {
                        Picker("How often?", selection: $durationIndex) {
                            ForEach(0 ..< durationCases.count ) { index in
                                Text(String(self.durationCases[index].rawValue))
                                    .tag(index)
                            }
                            
                        }
                        Button("Create Catchup") {
                            guard let contact = self.contact else { return }
                            self.done(Catchup(contact: contact, interval: Intervals.week.rawValue, method: .call))
                        }
                    }
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
}

struct ContactPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NewCatchupView() { catchup in
            //
        }
    }
}
