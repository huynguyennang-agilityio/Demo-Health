//
//  WatchConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

// WatchApp/Services/WatchConnectivityService.swift
import WatchConnectivity

final class WatchConnectivityService: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityService()
    var onCommandReceived: ((String) -> Void)?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendWorkoutData(_ data: WorkoutData) {
        guard WCSession.default.isReachable else { return }
        if let encoded = try? JSONEncoder().encode(data),
           let json = String(data: encoded, encoding: .utf8) {
            WCSession.default.sendMessage(["workout": json], replyHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let command = message["command"] as? String {
            onCommandReceived?(command)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
