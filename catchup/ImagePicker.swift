//
//  ImagePicker.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/30/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
