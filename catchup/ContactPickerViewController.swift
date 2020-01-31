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

struct ContactPickerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPickerViewController>) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: UIViewControllerRepresentableContext<ContactPickerViewController>) {
        
    }

//    var picked: (CNContact) -> Void
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(vc: vc, done: picked)
//    }
//
//    class Coordinator: NSObject, CNContactPickerDelegate {
//        var picked: (CNContact) -> Void
//        init(vc: CNContactPickerViewController, done: @escaping (CNContact) -> Void) {
//            self.picked = done
//            super.init()
//            vc.delegate = self
//        }
//        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//            picked(contact)
//        }
//    }
}
