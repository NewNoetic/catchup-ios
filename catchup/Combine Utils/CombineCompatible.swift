//
//  CombineCustom.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/1/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

protocol CombineCompatible { }
extension UIViewController: CombineCompatible { }
extension CombineCompatible where Self: UIViewControllerRepresentable {
    func completion() -> ViewControllerPublisher<Self> {
        return ViewControllerPublisher(viewController: self)
    }
}
