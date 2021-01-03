//
//  CatchupAction.swift
//  catchup
//
//  Created by Sidhant Gandhi on 12/15/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import SwiftUI
import MessageUI
import FirebaseAnalytics

extension Catchup {
    func perform() {
        switch self.method {
        case .call:
            guard let number = self.phoneNumber else {
                captureError(message: "trying to call, but phone number doesn't exist")
                return
            }
            guard let url = URL(string: "tel://\(number)") else {
                captureError(message: "trying to call, but can't create phone number url")
                return
            }
            UIApplication.shared.open(url)
            break
        case .text:
            guard let number = self.phoneNumber else {
                captureError(message: "trying to text, but phone number doesn't exist")
                return
            }
            guard MFMessageComposeViewController.canSendText() else {
                captureError(message: "trying to text, but not allowed")
                return
            }
            AppState.shared.startView = .text(recipients: [number])
            break
        case .email:
            guard let email = self.email else {
                captureError(message: "trying to email, but email doesn't exist")
                return
            }
            guard let gmailUrl = URL(string: "googlegmail:///co?to=\(email)") else {
                captureError(message: "couldn't get gmail app url")
                return
            }
            if UIApplication.shared.canOpenURL(gmailUrl) {
                Analytics.logEvent(AnalyticsEvent.CatchupEmailAppChosen.rawValue, parameters: [AnalyticsParameter.EmailApp.rawValue: EmailApp.Gmail.rawValue])
                UIApplication.shared.open(gmailUrl)
            } else {
                guard MFMailComposeViewController.canSendMail() else {
                    captureError(message: "trying to email, but not allowed")
                    return
                }
                Analytics.logEvent(AnalyticsEvent.CatchupEmailAppChosen.rawValue, parameters: [AnalyticsParameter.EmailApp.rawValue: EmailApp.iOSMail.rawValue])
                AppState.shared.startView = .email(recipients: [email])
            }
            break
        case .whatsapp:
            guard let number = self.phoneNumber else {
                captureError(message: "trying to whatsapp, but phone number doesn't exist")
                return
            }
            guard let whatsappUrl = URL(string: "https://wa.me/\(number)") else {
                captureError(message: "could not create whatsapp url from phone number")
                return
            }
            UIApplication.shared.open(whatsappUrl, options: [:], completionHandler: nil)
            break
        case .facetime:
            guard let number = self.phoneNumber else {
                captureError(message: "trying to facetime, but phone number doesn't exist")
                return
            }
            guard let facetimeUrl = URL(string: "facetime://\(number)") else {
                captureError(message: "could not create facetime url from phone number")
                return
            }
            UIApplication.shared.open(facetimeUrl, options: [:], completionHandler: nil)
            break
        }
    }
}
