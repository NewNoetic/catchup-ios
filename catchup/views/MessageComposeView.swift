//
//  MessageComposeView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 3/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

struct MessageComposeView: UIViewControllerRepresentable {
    var recipients: [String]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MessageComposeView>) -> MFMessageComposeViewController {
        let messageCompose = MFMessageComposeViewController()
        messageCompose.messageComposeDelegate = context.coordinator
        messageCompose.recipients = recipients
        return messageCompose
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: UIViewControllerRepresentableContext<MessageComposeView>) {
        // nothing
    }
    
    func makeCoordinator() -> MessageComposeView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(_ messageCompose: MessageComposeView) {
            self.parent = messageCompose
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                AppState.shared.startView = .catchups
            }
        }
    }
    
    typealias UIViewControllerType = MFMessageComposeViewController
}

class MessageComposerDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        AppState.shared.startView = .catchups
        controller.dismiss(animated: true)
    }
}

class MailComposerDelegate: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        AppState.shared.startView = .catchups
        controller.dismiss(animated: true)
    }
}
