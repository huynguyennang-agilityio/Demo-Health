//
//  WatchConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import WatchConnectivity
import Share

final class WatchConnectivityServiceWatch: NSObject, ObservableObject {
    static let shared = WatchConnectivityServiceWatch()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    /// Send arbitrary dictionary to phone. Uses sendMessage if reachable, fallback to transferUserInfo.
    func send(_ dict: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Watch send error: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(dict)
        }
    }
}

extension WatchConnectivityServiceWatch: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch WCSession activated: \(activationState.rawValue)")
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch reachability changed: \(session.isReachable)")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // handle incoming commands (start / pause / end)
        DispatchQueue.main.async {
            
            if let cmd = message["command"] as? String {
                NotificationCenter.default.post(name: .watchReceivedCommand, object: cmd)
            } else if message["startWorkout"] as? Bool == true {
                NotificationCenter.default.post(name: .watchReceivedCommand, object: "startWorkout")
            }
        }
    }
}

extension Notification.Name {
    static let watchReceivedCommand = Notification.Name("watchReceivedCommand")
}
