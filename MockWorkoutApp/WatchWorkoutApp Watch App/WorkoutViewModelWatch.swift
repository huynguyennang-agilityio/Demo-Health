import Foundation

class WorkoutViewModelWatch: ObservableObject {
    private var mockSession = MockWorkoutSession()
    private var timer: Timer?

    @Published var heartRate: Int = 0

    init() {
        WatchConnectivityManager.shared.delegate = self
    }

    func start() {
        mockSession.startWorkout()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            if self.mockSession.isRunning {
                self.heartRate = self.mockSession.simulatedHeartRate()
                WatchConnectivityManager.shared.sendMessage(["heartRate": self.heartRate])
                print("\(self.heartRate)")
            }
        }
    }

    func stop() {
        mockSession.stopWorkout()
        timer?.invalidate()
    }
}

extension WorkoutViewModelWatch: WatchConnectivityDelegate {
    func didReceiveData(_ data: [String : Any]) {
        if let hr = data["heartRate"] as? Int {
            DispatchQueue.main.async {
                self.heartRate = hr
            }
        }
    }
}
