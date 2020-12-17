//
//  MailComposeView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    var subject: String = ""
    var recipients: [String] = []
    var body: String = ""
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailComposeView>) -> MFMailComposeViewController {
        let mailCompose = MFMailComposeViewController()
        mailCompose.mailComposeDelegate = context.coordinator
        mailCompose.setToRecipients(recipients)
        mailCompose.setSubject(subject)
        mailCompose.setMessageBody(body, isHTML: false)
        return mailCompose
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailComposeView>) {
        // nothing
    }
    
    func makeCoordinator() -> MailComposeView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView

        init(_ mailCompose: MailComposeView) {
            self.parent = mailCompose
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                AppState.shared.startView = .catchups
            }
        }
    }
    
    typealias UIViewControllerType = MFMailComposeViewController
}
