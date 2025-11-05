import Foundation

class MockWorkoutSession {
    var isRunning = false
    var startDate: Date?
    var endDate: Date?

    func startWorkout() {
        isRunning = true
        startDate = Date()
        print("Workout started at \(startDate!)")
    }

    func stopWorkout() {
        isRunning = false
        endDate = Date()
        print("Workout ended at \(endDate!)")
    }

    func simulatedHeartRate() -> Int {
        return Int.random(in: 90...160)
    }

    func simulatedCalories() -> Double {
        return Double.random(in: 5...50)
    }

    func simulatedDistance() -> Double {
        return Double.random(in: 10...200)
    }
}