//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import Combine

@MainActor
final class WorkoutViewModel: ObservableObject {
    private let healthKitService = HealthKitService()
    private let connectivity = WatchConnectivityService.shared
    private let targetDistance: Double = 5_000

    @Published var heartRate = 0.0
    @Published var distance = 0.0
    @Published var calories = 0.0
    @Published var pace = 0.0
    @Published var isRunning = false
    @Published var isPaused = false

    init() {
        Task { await healthKitService.requestAuthorization() }
        startObserving()

        connectivity.onCommandReceived = { [weak self] cmd in
            guard let self = self else { return }
            switch cmd {
            case "start": self.startWorkout()
            case "pause": self.pauseWorkout()
            case "resume": self.resumeWorkout()
            case "end": self.endWorkout()
            default: break
            }
        }
    }

    private func startObserving() {
        Task.detached { [weak self] in
            guard let self = self else { return }

            for await _ in self.healthKitService.objectWillChange.values() {
                await MainActor.run {
                    self.heartRate = self.healthKitService.heartRate
                    self.distance = self.healthKitService.distance
                    self.calories = self.healthKitService.calories
                    self.pace = self.healthKitService.pace
                    self.isRunning = self.healthKitService.isRunning
                    self.isPaused = self.healthKitService.isPaused

                    let data = WorkoutData(
                        heartRate: self.heartRate,
                        distance: self.distance,
                        calories: self.calories,
                        pace: self.pace,
                        timestamp: Date()
                    )
                    self.connectivity.sendWorkoutData(data)

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

extension Publisher {
    func values() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink(
                receiveCompletion: { _ in continuation.finish() },
                receiveValue: { continuation.yield($0) }
            )
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
}
