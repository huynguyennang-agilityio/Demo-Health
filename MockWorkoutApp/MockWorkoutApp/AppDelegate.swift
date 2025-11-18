//
//  AppDelegate.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 18/11/25.
//

import UIKit
import WatchConnectivity

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Ensure the WatchConnectivityService singleton is instantiated early,
        // so it sets WCSession.delegate and activates before Watch sends messages.
        _ = WatchConnectivityService.shared
        return true
    }
}
