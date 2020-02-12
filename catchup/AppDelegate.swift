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
        
        defer {
            UIApplication.shared.applicationIconBadgeNumber = 0
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
            
            defer {
                Scheduler.shared.reschedule([catchup])
                .then { scheduledOrError in
                        try scheduledOrError.compactMap { $0.value }.forEach { try Database.shared.upsert(catchup: $0) }
                        scheduledOrError.compactMap { $0.error }.forEach { print($0.localizedDescription) } // TODO: grab individual errors and catchups from them if provided
                }
                .catch { error in
                    print("could not reschedule some or all catchups")
                }
            }
            
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
                window?.rootViewController?.present(compose, animated: true)
            case .email:
                guard let email = catchup.email else {
                    print("trying to call, but email doesn't exist")
                    return
                }
                guard MFMailComposeViewController.canSendMail() else {
                    print("trying to email, but not allowed")
                    return
                }
                let compose = MFMailComposeViewController()
                compose.setToRecipients([email])
                window?.rootViewController?.present(compose, animated: true)
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
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(#function)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print(#function)
    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        print(#function)
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print(#function)
    }
    
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        print(#function)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print(#function)
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let notificationResponse = connectionOptions.notificationResponse {
            print("notification: \(notificationResponse.notification.request.identifier)")
        }
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(Upcoming())
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

