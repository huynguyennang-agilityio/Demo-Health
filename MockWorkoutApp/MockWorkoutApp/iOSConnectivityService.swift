//
//  iOSConnectivityService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 7/11/25.
//

// iOSApp/Services/iOSConnectivityService.swift
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
        guard WCSession.default.isReachable else { return }
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
