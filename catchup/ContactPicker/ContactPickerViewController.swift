//
//  ContactPicker.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import UIKit
import ContactsUI
import Combine

struct ContactPickerViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ContactPickerViewControllerWrapper
    typealias DoneSignature = (CNContact?) -> Void
    var done: DoneSignature
    
    init(done: @escaping DoneSignature) {
        self.done = done
    }
    
    func makeCoordinator() -> ContactPickerViewController.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPickerViewController>) -> ContactPickerViewControllerWrapper {
        let picker = ContactPickerViewControllerWrapper()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ContactPickerViewControllerWrapper, context: UIViewControllerRepresentableContext<ContactPickerViewController>) {
        
    }
        
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerViewController
        
        init(_ contactPickerViewController: ContactPickerViewController) {
            self.parent = contactPickerViewController
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            self.parent.done(nil)
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            self.parent.done(contact)
        }
    }
}
