//
//  WatchConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 12/11/25.
//

import Foundation
import WatchConnectivity
import Combine
import Share

/// Centralized WatchConnectivity service for the iPhone side.
/// - NOTE: This object sets up WCSession early (in init), so make sure `WatchConnectivityService.shared`
///   is referenced early (AppDelegate or app entry) so delegate/activation happen before Watch sends messages.
final class WatchConnectivityService: NSObject, ObservableObject {
    public static let shared = WatchConnectivityService()
    
    @Published public private(set) var latestData: WorkoutData?
    @Published public private(set) var watchIsReady: Bool = false
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        guard WCSession.isSupported() else {
            print("⚠️ WCSession not supported on this device.")
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    /// Send a simple command to the watch. Uses sendMessage when reachable, otherwise fallback to transferUserInfo.
    public func sendCommand(_ command: String) {
        let session = WCSession.default
        let payload = ["command": command]
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { error in
                print("WC sendMessage error: \(error.localizedDescription)")
            }
        } else {
            // queued transfer if watch not currently reachable
            session.transferUserInfo(payload)
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityService: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activationDidComplete: \(activationState.rawValue) error: \(String(describing: error))")
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) { /* Not used for phone side here */ }
    public func sessionDidDeactivate(_ session: WCSession) { /* Not used for phone side here */ }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        // If watch became reachable, we do not auto-start workout here; UI checks watchIsReady flag or message.
        print("WCSession reachability changed: isReachable=\(session.isReachable)")
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 1) watchReady message: watch app is in foreground and ready
        DispatchQueue.main.async {
            if message["watchReady"] as? Bool == true {
                DispatchQueue.main.async {
                    self.watchIsReady = true
                }
                return
            }
            
            // 2) workout data message
            if let json = message["workout"] as? String,
               let data = json.data(using: .utf8),
               let workout = try? JSONDecoder().decode(WorkoutData.self, from: data) {
                DispatchQueue.main.async {
                    self.latestData = workout
                }
            }
        }
        
        
    }
    
    // fallback: userInfo transfer (delivered when session becomes active)
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            
            if userInfo["watchReady"] as? Bool == true {
                DispatchQueue.main.async { self.watchIsReady = true }
                return
            }
            if let dict = userInfo["workout"] as? Data,
               let workout = try? JSONDecoder().decode(WorkoutData.self, from: dict) {
                DispatchQueue.main.async { self.latestData = workout }
            }
        }
    }
}
