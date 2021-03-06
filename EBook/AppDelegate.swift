//
//  AppDelegate.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        AppManager.shared.applicationEnterance(withWindow: window!, launchOptions: launchOptions)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppManager.shared.applicationDidBecomeActive()
    }

}

