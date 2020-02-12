//
//  AppDelegate.swift
//  catchup
//
//  Created by Sidhant Gandhi on 1/29/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import UIKit
import Promises
import UserNotifications
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        UserNotificationsAsync.authenticate()
            .then { _ in }
            .catch { error in
                print("error authenticating user notifications: \(error.localizedDescription)")
        }
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        defer {
            completionHandler()
        }
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // TODO: Snooze?
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let identifier = response.notification.request.identifier
            guard let catchup = Database.shared.catchup(notification: identifier) else {
                print("could not find saved catchup with that identifier")
                return
            }
            switch catchup.method {
            case .call:
                guard let number = catchup.phoneNumber else {
                    print("trying to call, but phone number doesn't exist")
                    return
                }
                guard let url = URL(string: number) else {
                    print("trying to call, but can't create phone number url")
                    return
                }
                UIApplication.shared.open(url)
            case .text:
                guard let number = catchup.phoneNumber else {
                    print("trying to call, but phone number doesn't exist")
                    return
                }
                guard MFMessageComposeViewController.canSendText() else {
                    print("trying to text, but not allowed")
                    return
                }
                let compose = MFMessageComposeViewController()
                compose.recipients = [number]
                // TODO: do something?
            case .email:
                print("email")
                // TODO: email
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

