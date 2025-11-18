//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import Combine
import Share
import WatchConnectivity

/// Enum representing the watch availability state used by the UI.
enum WatchStatus {
    case notPaired
    case notInstalled
    case notReachable
    case ready
}

@MainActor
final class WorkoutViewModel: ObservableObject {
    // live metrics
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var calories: Double = 0
    @Published var pace: Double = 0

    // UI / workflow state
    @Published var isRunning: Bool = false
    @Published var watchStatus: WatchStatus = .notReachable
    @Published var showWatchAlert: Bool = false

    private let connectivity = WatchConnectivityService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Keep metrics updated from connectivity service
        connectivity.$latestData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.heartRate = data.heartRate
                self.distance = data.distance
                self.calories = data.calories
                self.pace = data.pace
            }
            .store(in: &cancellables)

        // When watch signals readiness, update UI and auto-start if appropriate
        connectivity.$watchIsReady
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ready in
                guard let self = self else { return }
                if ready {
                    self.watchStatus = .ready
                    // If alert still visible, dismiss it and start the workout automatically.
                    if self.showWatchAlert {
                        self.showWatchAlert = false
                    }
                    print("Close alert")
                    if !self.isRunning {
                        print("Start workout")
                        self.startWorkoutNow()
                    }
                }
            }
            .store(in: &cancellables)

        // initial status check
        _ = updateWatchStatus()
    }

    // MARK: - Public actions (called by the View)

    /// Called when user taps Start on iPhone.
    func startWorkoutTapped() {
        if updateWatchStatus() == false {
            // watch not ready → prompt user to open the Watch app
            showWatchAlert = true
            return
        }
        // watch ready → start now
        startWorkoutNow()
    }

    func pauseWorkout() {
        connectivity.sendCommand("pauseWorkout")
    }

    func resumeWorkout() {
        connectivity.sendCommand("resumeWorkout")
    }

    func endWorkout() {
        connectivity.sendCommand("endWorkout")
        isRunning = false
    }

    // MARK: - Internal helpers

    private func startWorkoutNow() {
        // send start command and flip UI
        connectivity.sendCommand("startWorkout")
        isRunning = true
    }

    /// Check pairing / installation / reachability and update watchStatus.
    /// Returns true if watch appears ready right now (reachable).
    @discardableResult
    func updateWatchStatus() -> Bool {
        let session = WCSession.default
        if !session.isPaired {
            watchStatus = .notPaired
            return false
        }
        if !session.isWatchAppInstalled {
            watchStatus = .notInstalled
            return false
        }
        if !session.isReachable {
            watchStatus = .notReachable
            return false
        }
        watchStatus = .ready
        return true
    }
}

