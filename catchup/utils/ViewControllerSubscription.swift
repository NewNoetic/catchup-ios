//
//  ViewControllerSubscription.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Combine
import SwiftUI

final class ViewControllerSubscription<SubscriberType: Subscriber, ViewController: UIViewControllerRepresentable>: Subscription where SubscriberType.Input == ViewController {
    private var subscriber: SubscriberType?
    private let viewController: ViewController

    init(subscriber: SubscriberType, viewController: ViewController) {
        self.subscriber = subscriber
        self.viewController = viewController
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }

    func done() {
        _ = subscriber?.receive(viewController)
    }
}
