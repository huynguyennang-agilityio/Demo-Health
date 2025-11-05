import Foundation
import WatchConnectivity

class WorkoutViewModel: NSObject, ObservableObject {
    private var mockSession = MockWorkoutSession()
    private var timer: Timer?

    @Published var heartRate: Int = 0
    @Published var calories: Double = 0
    @Published var distance: Double = 0

    override init() {
        super.init()
        IOSConnectivity.shared.delegate = self
    }

    func start() {
        mockSession.startWorkout()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            if self.mockSession.isRunning {
                self.heartRate = self.mockSession.simulatedHeartRate()
                self.calories += self.mockSession.simulatedCalories()
                self.distance += self.mockSession.simulatedDistance()

                IOSConnectivity.shared.sendMessage(
                    ["heartRate": self.heartRate,
                     "calories": self.calories,
                     "distance": self.distance]
                )
            }
        }
    }

    func stop() {
        mockSession.stopWorkout()
        timer?.invalidate()
    }
}

extension WorkoutViewModel: IOSConnectivityDelegate {
    func didReceiveData(_ data: [String : Any]) {
        if let hr = data["heartRate"] as? Int {
            DispatchQueue.main.async {
                self.heartRate = hr
            }
        }
    }
}
