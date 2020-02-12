//
//  ViewControllerPublisher.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Combine
import SwiftUI

struct ViewControllerPublisher<ViewController: UIViewControllerRepresentable>: Publisher {

    typealias Output = ViewController
    typealias Failure = Never

    let viewController: ViewController

    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == ViewControllerPublisher.Failure, S.Input == ViewControllerPublisher.Output {
        let subscription = ViewControllerSubscription(subscriber: subscriber, viewController: self.viewController)
        subscriber.receive(subscription: subscription)
    }
}
