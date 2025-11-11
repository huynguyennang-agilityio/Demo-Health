//
//  iOSConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 7/11/25.
//

import Foundation
import WatchConnectivity

final class iOSConnectivityService: NSObject, WCSessionDelegate {
    static let shared = iOSConnectivityService()
    private override init() { super.init(); activate() }

    @Published var latestData: WorkoutData?

    private func activate() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendCommand(_ command: String) {
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity not supported on this device.")
            return
        }
        
        guard WCSession.default.isPaired else {
            print("⚠️ No Apple Watch paired with this iPhone.")
            return
        }
        
        guard WCSession.default.isWatchAppInstalled else {
            print("⚠️ The Watch app is not installed.")
            return
        }
        
        guard WCSession.default.isReachable else {
            print("⚠️ Apple Watch is not currently reachable (may be locked or out of range).")
            return
        }

        WCSession.default.sendMessage(["command": command], replyHandler: nil)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let json = message["workout"] as? String,
              let data = json.data(using: .utf8),
              let workout = try? JSONDecoder().decode(WorkoutData.self, from: data)
        else { return }
        DispatchQueue.main.async {
            self.latestData = workout
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
