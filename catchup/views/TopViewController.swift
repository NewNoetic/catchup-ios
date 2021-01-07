//
//  TopViewController.swift
//  catchup
//
//  Created by SG on 1/6/21.
//  Copyright © 2021 newnoetic. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Top most view controller in view hierarchy
    var topMostViewController: UIViewController {

        // No presented view controller? Current controller is the most view controller
        guard let presentedViewController = self.presentedViewController else {
            return self
        }

        // Presenting a navigation controller?
        // Top most view controller is in visible view controller hierarchy
        if let navigation = presentedViewController as? UINavigationController {
            if let visibleController = navigation.visibleViewController {
                return visibleController.topMostViewController
            } else {
                return navigation.topMostViewController
            }
        }

        // Presenting a tab bar controller?
        // Top most view controller is in visible view controller hierarchy
        if let tabBar = presentedViewController as? UITabBarController {
            if let selectedTab = tabBar.selectedViewController {
                return selectedTab.topMostViewController
            } else {
                return tabBar.topMostViewController
            }
        }

        // Presenting another kind of view controller?
        // Top most view controller is in visible view controller hierarchy
        return presentedViewController.topMostViewController
    }

}

extension UIWindow {

    /// Top most view controller in view hierarchy
    /// - Note: Wrapper to UIViewController.topMostViewController
    var topMostViewController: UIViewController? {
        return self.rootViewController?.topMostViewController
    }

}

extension UIApplication {

    /// Top most view controller in view hierarchy
    /// - Note: Wrapper to UIWindow.topMostViewController
    var topMostViewController: UIViewController? {
        return self.windows.first?.topMostViewController
    }
}
