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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIWindowSceneDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Migration.run()
        
        UNUserNotificationCenter.current().delegate = self
        
        // SceneDelegate.appState.startView = .intro
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        
        let identifier = response.notification.request.identifier
        guard let catchup = Database.shared.catchup(notification: identifier) else {
            print("could not find saved catchup with that identifier")
            return
        }
        
        defer {
            Scheduler.shared.reschedule([catchup])
            .then { scheduledOrError in
                    try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                    scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
            }
            .catch { error in
                print("could not reschedule some or all catchups")
            }
            .always {
                UIApplication.shared.applicationIconBadgeNumber = 0
                completionHandler()
            }
        }
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // TODO: Snooze?
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            switch catchup.method {
            case .call:
                guard let number = catchup.phoneNumber else {
                    print("trying to call, but phone number doesn't exist")
                    return
                }
                guard let url = URL(string: "tel://\(number)") else {
                    print("trying to call, but can't create phone number url")
                    return
                }
                UIApplication.shared.open(url)
                break
            case .text:
                guard let number = catchup.phoneNumber else {
                    print("trying to text, but phone number doesn't exist")
                    return
                }
                guard MFMessageComposeViewController.canSendText() else {
                    print("trying to text, but not allowed")
                    return
                }
                SceneDelegate.appState.startView = .text(recipients: [number])
                break
            case .email:
                guard let email = catchup.email else {
                    print("trying to email, but email doesn't exist")
                    return
                }
                guard MFMailComposeViewController.canSendMail() else {
                    print("trying to email, but not allowed")
                    return
                }
                SceneDelegate.appState.startView = .email(recipients: [email])
                break
            case .whatsapp:
                guard let number = catchup.phoneNumber else {
                    print("trying to whatsapp, but phone number doesn't exist")
                    return
                }
                guard let whatsappUrl = URL(string: "https://wa.me/\(number)") else {
                    print("could not create whatsapp url from phone number")
                    return
                }
                UIApplication.shared.open(whatsappUrl, options: [:], completionHandler: nil)
                break
            case .facetime:
                guard let number = catchup.phoneNumber else {
                    print("trying to facetime, but phone number doesn't exist")
                    return
                }
                guard let facetimeUrl = URL(string: "facetime://\(number)") else {
                    print("could not create facetime url from phone number")
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

