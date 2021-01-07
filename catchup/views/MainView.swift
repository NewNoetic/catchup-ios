//
//  MainView.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

struct MainView: View {
    @EnvironmentObject var state: AppState
    public static var accentColor = Color(red: 1, green: 91.0/255.0, blue: 91.0/255.0)
    var mailComposeDelegate = MailComposerDelegate()
    var messageComposeDelgate = MessageComposerDelegate()
    
    var body: some View {
        let contentView = ContentView().environmentObject(Upcoming())
            .accentColor(MainView.accentColor)
        return Group {
            switch self.state.startView {
            case .intro1: IntroView()
                .accentColor(MainView.accentColor)
            case .catchups:
                contentView
            default:
                contentView
                    .onAppear {
                        switch self.state.startView {
                        case let .text(recipients):
                            self.presentMessageCompose(recipients: recipients)
                        case let .email(recipients):
                            self.presentMailCompose(recipients: recipients)
                        default:
                            print("")
                        }
                    }
            }
        }
    }
}

// MARK: The mail part
extension MainView {
    /// Present an mail compose view controller modally in UIKit environment
    private func presentMailCompose(recipients: [String]) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        if let topmost = UIApplication.shared.windows.first?.topMostViewController {
            topmost.dismiss(animated: false)
        }
        
        guard let vc = UIApplication.shared.windows.first?.rootViewController else {
            captureError(message: "Could not get root view controller when presenting message/mail compose vc")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.setToRecipients(recipients)
        composeVC.mailComposeDelegate = self.mailComposeDelegate
        
        vc.present(composeVC, animated: true)
    }
}

// MARK: The message part
extension MainView {
    /// Present an message compose view controller modally in UIKit environment
    private func presentMessageCompose(recipients: [String]) {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        if let topmost = UIApplication.shared.windows.first?.topMostViewController {
            topmost.dismiss(animated: false)
        }
        
        guard let vc = UIApplication.shared.windows.first?.rootViewController else {
            captureError(message: "Could not get root view controller when presenting message/mail compose vc")
            return
        }
        
        let composeVC = MFMessageComposeViewController()
        composeVC.recipients = recipients
        composeVC.messageComposeDelegate = self.messageComposeDelgate
        
        vc.present(composeVC, animated: true)
    }
}
