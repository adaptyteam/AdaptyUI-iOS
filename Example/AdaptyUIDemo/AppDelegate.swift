//
//  AppDelegate.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.1.23..
//

import Adapty
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.logLevel = .verbose
        Adapty.activate("public_live_iNuUlSsN.83zcTTR8D5Y8FI9cGUI6")
        return true
    }
}
