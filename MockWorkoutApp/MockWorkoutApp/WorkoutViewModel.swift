import Foundation
import WatchConnectivity

@MainActor
final class WorkoutViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var latestData: WorkoutData?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let json = message["workout"] as? String,
              let data = json.data(using: .utf8),
              let workout = try? JSONDecoder().decode(WorkoutData.self, from: data)
        else { return }
        latestData = workout
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
