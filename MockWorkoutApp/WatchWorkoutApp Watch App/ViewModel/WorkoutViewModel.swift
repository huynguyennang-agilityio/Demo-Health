//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import Combine
import SwiftUI
import HealthKit
import WatchConnectivity
import Share

@MainActor
final class WatchWorkoutViewModel: ObservableObject {
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var calories: Double = 0
    @Published var pace: Double = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false

    private let healthKitService = HealthKitService()
    private let connectivity = WatchConnectivityService.shared
    private let targetDistance: Double = 5000

    private var cancellables = Set<AnyCancellable>()

    init() {
        Task { await healthKitService.requestAuthorization() }

        // Lắng nghe HealthKit updates
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

                    // Gửi dữ liệu về iOS
                    let data = WorkoutData(
                        heartRate: self.heartRate,
                        distance: self.distance,
                        calories: self.calories,
                        pace: self.pace,
                        timestamp: Date()
                    )

                    if WCSession.default.isReachable {
                        if let json = try? JSONEncoder().encode(data),
                           let jsonString = String(data: json, encoding: .utf8) {
                            WCSession.default.sendMessage(["workout": jsonString], replyHandler: nil)
                        }
                    } else {
                        WCSession.default.transferUserInfo(["workout": data])
                    }

                    // Kết thúc tự động nếu đạt target
                    if self.distance >= self.targetDistance {
                        self.healthKitService.end()
                    }
                }
            }
        }

        // Lắng nghe command từ iOS
        connectivity.onCommandReceived = { [weak self] cmd in
            guard let self = self else { return }
            switch cmd {
            case "startWorkout": self.healthKitService.startWorkout()
            case "pauseWorkout": self.healthKitService.pause()
            case "resumeWorkout": self.healthKitService.resume()
            case "endWorkout": self.healthKitService.end()
            default: break
            }
        }
    }
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
