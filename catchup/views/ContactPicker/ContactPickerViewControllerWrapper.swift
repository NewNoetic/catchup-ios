//
//  ContactPickerViewControllerWrapper.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/31/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import UIKit
import ContactsUI

/// We create a wrapper for the contact picker because just presenting it via `UIViewControllerRepresentable`
/// results in a blank screen. BUG!
class ContactPickerViewControllerWrapper: UIViewController, CNContactPickerDelegate {
    var delegate: CNContactPickerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        let contacts = CNContactPickerViewController()
        contacts.delegate = self.delegate
        self.present(contacts, animated: false, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.delegate?.contactPickerDidCancel?(picker)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.delegate?.contactPicker?(picker, didSelect: contact)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        self.delegate?.contactPicker?(picker, didSelect: contacts)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        self.delegate?.contactPicker?(picker, didSelect: contactProperty)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
        self.delegate?.contactPicker?(picker, didSelectContactProperties: contactProperties)
    }
}
