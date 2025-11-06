//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation

@MainActor
final class WorkoutViewModel: ObservableObject {
    private let healthKitService = HealthKitService()
    private let connectivity = WatchConnectivityService.shared

    @Published var heartRate = 0.0
    @Published var distance = 0.0
    @Published var calories = 0.0
    @Published var pace = 0.0
    @Published var isRunning = false
    @Published var isPaused = false

    private let targetDistance: Double = 5_000  // auto stop sau 5km

    init() {
        Task { await healthKitService.requestAuthorization() }
        startObserving()
    }

    private func startObserving() {
        Task.detached { [weak self] in
            for await _ in self?.healthKitService.objectWillChange.sequence() ?? AsyncStream({ _ in }) {
                guard let self = self else { continue }
                await MainActor.run {
                    self.heartRate = self.healthKitService.heartRate
                    self.distance = self.healthKitService.distance
                    self.calories = self.healthKitService.calories
                    self.pace = self.healthKitService.pace
                    self.isRunning = self.healthKitService.isRunning
                    self.isPaused = self.healthKitService.isPaused

                    // gửi lên iPhone
                    let data = WorkoutData(
                        heartRate: self.heartRate,
                        distance: self.distance,
                        calories: self.calories,
                        pace: self.pace,
                        timestamp: Date()
                    )
                    self.connectivity.sendWorkoutData(data)

                    // Auto stop nếu đủ km
                    if self.distance >= self.targetDistance {
                        self.healthKitService.end()
                    }
                }
            }
        }
    }

    func startWorkout() { healthKitService.startWorkout() }
    func pauseWorkout() { healthKitService.pause() }
    func resumeWorkout() { healthKitService.resume() }
    func endWorkout() { healthKitService.end() }
}
