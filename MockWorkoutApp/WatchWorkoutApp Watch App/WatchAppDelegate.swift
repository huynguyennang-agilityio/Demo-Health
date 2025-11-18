//
//  WatchAppDelegate.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 18/11/25.
//

import SwiftUI
import WatchConnectivity

// 1️⃣ Tạo AppDelegate cho Watch
class WatchAppDelegate: NSObject, WKApplicationDelegate {
    
    func applicationDidBecomeActive() {
        if WCSession.default.activationState == .activated {
            WCSession.default.sendMessage(["watchReady": true], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func applicationWillEnterForeground() {
        if WCSession.default.activationState == .activated {
            WCSession.default.sendMessage(["watchReady": true], replyHandler: nil, errorHandler: nil)
        }
    }
}
