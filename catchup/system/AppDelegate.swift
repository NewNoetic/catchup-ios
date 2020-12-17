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
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIWindowSceneDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Analytics
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        Analytics.setUserID(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)
        Analytics.setUserProperty(TimeZone.current.identifier, forName:AnalyticsParameter.Timezone.rawValue)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
        
        // Database and user defaults migration
        Migration.run()
        
        // Arguments
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
        if arguments.contains("-testing") {
            print("detected testing env: disabling analytics collection")
            Analytics.setAnalyticsCollectionEnabled(false)
        }
        if arguments.contains("--disableIntro") {
            AppState.shared.startView = .catchups
        }
        
        // Notifications
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

            catchup.perform()
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

