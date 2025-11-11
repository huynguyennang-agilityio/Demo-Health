//
//  WatchConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import WatchConnectivity

/// A singleton service to handle communication between Watch and iOS
final class WatchConnectivityService: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityService()
    
    /// Closure for ViewModel to receive commands directly
    var onCommandReceived: ((String) -> Void)?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    /// Send workout data to the iOS app
    func sendWorkoutData(_ data: WorkoutData) {
        guard WCSession.default.isReachable else { return }
        if let encoded = try? JSONEncoder().encode(data),
           let json = String(data: encoded, encoding: .utf8) {
            WCSession.default.sendMessage(["workout": json], replyHandler: nil)
        }
    }
    
    // MARK: - WCSessionDelegate
    
    /// Called when a realtime message is received from iOS
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let command = message["command"] as? String {
            // Trigger the closure for immediate handling
            onCommandReceived?(command)
            // Post notification so NotificationCenter publisher can receive it
            NotificationCenter.default.post(name: .didReceiveWorkoutCommand, object: command)
        }
    }
    
    /// Called when a message is received via transferUserInfo (background / killed app)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let command = userInfo["command"] as? String {
            onCommandReceived?(command)
            NotificationCenter.default.post(name: .didReceiveWorkoutCommand, object: command)
        }
    }
    
    // Required stubs for WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

// Notification name for posting workout commands internally
extension Notification.Name {
    static let didReceiveWorkoutCommand = Notification.Name("didReceiveWorkoutCommand")
}
