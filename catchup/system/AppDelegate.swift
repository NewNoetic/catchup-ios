//
//  AppDelegate.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import UIKit
import SwiftUI
import Promises
import UserNotifications
import MessageUI
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIWindowSceneDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let arguments = CommandLine.arguments
        if arguments.contains("--disableAnimation") {
            UIView.setAnimationsEnabled(false)
        }
        
        if arguments.contains("--resetData") {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            do {
                try Database.shared.deleteAll()
            } catch {
                captureError(error, message: "Could not reset catchups")
            }
        }
        
        FirebaseApp.configure()
        
        Analytics.setUserID(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
        Analytics.setUserProperty(TimeZone.current.identifier, forName:AnalyticsParameter.Timezone.rawValue)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
        
        Migration.run()
        
        UNUserNotificationCenter.current().delegate = self
        
        // Gives us callback for 'dismissed' notifications
        let notificationCategory = UNNotificationCategory(identifier: Notifications.defaultCategoryIdentifier, actions: [], intentIdentifiers: [], options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        
        let identifier = response.notification.request.identifier
        guard let catchup = Database.shared.catchup(notification: identifier) else {
            captureError(message: "could not find saved catchup with that identifier")
            return
        }
        
        defer {
            let expiredCatchups = (try? Database.shared.expiredCatchups()) ?? []
            Scheduler.shared.reschedule([catchup] + expiredCatchups)
            .then { scheduledOrError in
                    try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                    scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
            }
            .catch { error in
                captureError(error, message:"could not reschedule some or all catchups")
            }
            .always {
                UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = notifications.count
                    }
                }
                completionHandler()
            }
        }
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // TODO: Snooze?
            Analytics.logEvent(AnalyticsEvent.NotificationTapped.rawValue, parameters: [
                AnalyticsParameter.NotificationAction.rawValue: "dismiss",
                AnalyticsParameter.CatchupMethod.rawValue: catchup.method.rawValue,
                AnalyticsParameter.CatchupInterval.rawValue: "\(catchup.interval)",
                AnalyticsParameter.CatchupDate.rawValue: catchup.nextTouch?.debugDescription ?? ""
            ])
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            Analytics.logEvent(AnalyticsEvent.NotificationTapped.rawValue, parameters: [
                AnalyticsParameter.NotificationAction.rawValue: "default",
                AnalyticsParameter.CatchupMethod.rawValue: catchup.method.rawValue,
                AnalyticsParameter.CatchupInterval.rawValue: "\(catchup.interval)",
                AnalyticsParameter.CatchupDate.rawValue: catchup.nextTouch?.debugDescription ?? ""
            ])

            switch catchup.method {
            case .call:
                guard let number = catchup.phoneNumber else {
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
                guard let number = catchup.phoneNumber else {
                    captureError(message: "trying to text, but phone number doesn't exist")
                    return
                }
                guard MFMessageComposeViewController.canSendText() else {
                    captureError(message: "trying to text, but not allowed")
                    return
                }
                SceneDelegate.appState.startView = .text(recipients: [number])
                break
            case .email:
                guard let email = catchup.email else {
                    captureError(message: "trying to email, but email doesn't exist")
                    return
                }
                guard MFMailComposeViewController.canSendMail() else {
                    captureError(message: "trying to email, but not allowed")
                    return
                }
                SceneDelegate.appState.startView = .email(recipients: [email])
                break
            case .whatsapp:
                guard let number = catchup.phoneNumber else {
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
                guard let number = catchup.phoneNumber else {
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(#function)
        completionHandler(.alert)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if let resp = options.notificationResponse {
            print(#function)
            print(resp.notification.request.identifier)
        }
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

