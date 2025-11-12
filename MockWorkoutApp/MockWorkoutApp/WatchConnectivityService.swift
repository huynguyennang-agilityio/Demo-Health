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

@MainActor
public class WatchConnectivityService: NSObject, WCSessionDelegate {
    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    nonisolated public func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    public static let shared = WatchConnectivityService()
    private override init() { super.init(); activate() }
    
    @Published public var latestData: WorkoutData?
    
    private func activate() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    public func sendCommand(_ command: String) {
        let session = WCSession.default
        
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity not supported on this device.")
            return
        }
        
        guard session.isPaired else {
            print("⚠️ No Apple Watch paired with this iPhone.")
            return
        }
        
        guard session.isWatchAppInstalled else {
            print("⚠️ The Watch app is not installed.")
            return
        }
        
        if session.isReachable {
            session.sendMessage(["command": command], replyHandler: nil)
        } else {
            print("⚠️ Apple Watch is not currently reachable (may be locked or out of range).")
            session.transferUserInfo(["command": command])
        }
    }
    
    nonisolated public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let json = message["workout"] as? String,
              let data = json.data(using: .utf8),
              let workout = try? JSONDecoder().decode(WorkoutData.self, from: data)
        else { return }
        DispatchQueue.main.async { [weak self] in
            self!.latestData = workout
        }
    }
    
    nonisolated public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
