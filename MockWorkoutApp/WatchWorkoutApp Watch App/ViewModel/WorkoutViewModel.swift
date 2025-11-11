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
import SwiftUI
import HealthKit
import WatchConnectivity

@MainActor
final class WorkoutViewModel: ObservableObject {
    
    private let healthKitService = HealthKitService()
    private let connectivity = WatchConnectivityService.shared
    private let targetDistance: Double = 5_000
    
    // MARK: - Published properties for UI binding
    @Published var heartRate = 0.0
    @Published var distance = 0.0
    @Published var calories = 0.0
    @Published var pace = 0.0
    @Published var isRunning = false
    @Published var isPaused = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Request HealthKit authorization
        Task { await healthKitService.requestAuthorization() }
        
        // Observe HealthKit updates
        startObserving()
        
        // Listen to commands from WatchConnectivityService via NotificationCenter
        startListeningCommands()
        
        // Optional: direct closure callback
        connectivity.onCommandReceived = { [weak self] cmd in
            self?.handleCommand(cmd)
        }
    }
    
    // MARK: - Observe HealthKit data continuously
    private func startObserving() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            // Async stream of HealthKit objectWillChange
            for await _ in self.healthKitService.objectWillChange.values() {
                await MainActor.run {
                    self.heartRate = self.healthKitService.heartRate
                    self.distance = self.healthKitService.distance
                    self.calories = self.healthKitService.calories
                    self.pace = self.healthKitService.pace
                    self.isRunning = self.healthKitService.isRunning
                    self.isPaused = self.healthKitService.isPaused
                    
                    // Send workout data to iOS app
                    let data = WorkoutData(
                        heartRate: self.heartRate,
                        distance: self.distance,
                        calories: self.calories,
                        pace: self.pace,
                        timestamp: Date()
                    )
                    
                    if WCSession.default.isReachable {
                        // Realtime message
                        if let json = try? JSONEncoder().encode(data),
                           let jsonString = String(data: json, encoding: .utf8) {
                            WCSession.default.sendMessage(["workout": jsonString], replyHandler: nil)
                        }
                    } else {
                        // Send via transferUserInfo for background / killed iOS app
                        WCSession.default.transferUserInfo(["workout": data])
                    }
                    
                    // Automatically end workout if target distance is reached
                    if self.distance >= self.targetDistance {
                        self.healthKitService.end()
                    }
                }
            }
        }
    }
    
    // MARK: - Listen to commands via NotificationCenter publisher
    private func startListeningCommands() {
        NotificationCenter.default.publisher(for: .didReceiveWorkoutCommand)
            .compactMap { $0.object as? String }
            .sink { [weak self] cmd in
                self?.handleCommand(cmd)
            }
            .store(in: &cancellables)
    }
    
    /// Handles start/pause/resume/end commands
    private func handleCommand(_ command: String) {
        switch command {
        case "start": startWorkout()
        case "pause": pauseWorkout()
        case "resume": resumeWorkout()
        case "end": endWorkout()
        default: break
        }
    }
    
    // MARK: - Workout actions
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
