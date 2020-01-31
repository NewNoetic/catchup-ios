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
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPickerViewController>) -> ContactPickerViewControllerWrapper {
        let picker = ContactPickerViewControllerWrapper()
        picker.delegate = nil // TODO: Set
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ContactPickerViewControllerWrapper, context: UIViewControllerRepresentableContext<ContactPickerViewController>) {
        
    }
    
    typealias UIViewControllerType = ContactPickerViewControllerWrapper
}
