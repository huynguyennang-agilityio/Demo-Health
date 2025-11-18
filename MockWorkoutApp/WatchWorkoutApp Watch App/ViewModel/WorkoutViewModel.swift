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
final class WatchWorkoutViewModel: NSObject, ObservableObject {

    @Published var workoutStarted = false
    @Published var heartRate = 0.0
    @Published var distance = 0.0
    @Published var calories = 0.0
    @Published var pace = 0.0

    private let connectivity = WatchConnectivityServiceWatch.shared
    private let hk = HealthKitService()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        // Observe commands from iPhone
        NotificationCenter.default.publisher(for: .watchReceivedCommand)
            .compactMap { $0.object as? String }
            .sink { [weak self] cmd in
                guard let self else { return }
                switch cmd {
                case "startWorkout":
                    self.startWorkout()
                case "pauseWorkout":
                    self.pauseWorkout()
                case "resumeWorkout":
                    self.resumeWorkout()
                case "endWorkout":
                    self.endWorkout()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        observeHealthKit()
    }

    /// Notify the phone that watch app is ready
    func notifyPhoneReady() {
        print("Wactch: Sending watchReady to iPhone")
        connectivity.send(["watchReady": true])
    }

    /// MARK: - Workout control

    func startWorkout() {
        workoutStarted = true
        hk.startWorkout()
    }

    func pauseWorkout() {
        hk.pause()
    }

    func resumeWorkout() {
        hk.resume()
    }

    func endWorkout() {
        workoutStarted = false
        hk.end()
    }

    /// MARK: - Mirror HealthKitService updates into ViewModel Publishers
    private func observeHealthKit() {
        hk.$heartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hr in
                self?.heartRate = hr
                self?.sendWorkoutDataToPhone()
            }
            .store(in: &cancellables)

        hk.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dist in
                self?.distance = dist
                self?.sendWorkoutDataToPhone()
            }
            .store(in: &cancellables)

        hk.$calories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cal in
                self?.calories = cal
                self?.sendWorkoutDataToPhone()
            }
            .store(in: &cancellables)

        hk.$pace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pace in
                self?.pace = pace
                self?.sendWorkoutDataToPhone()
            }
            .store(in: &cancellables)
    }
    
    private func sendWorkoutDataToPhone() {
        guard workoutStarted else { return }
        
        let data = WorkoutData(
            heartRate: heartRate,
            distance: distance,
            calories: calories,
            pace: pace,
            timestamp: Date()
        )
        
        // Encode to JSON string
        if let encoded = try? JSONEncoder().encode(data),
           let jsonString = String(data: encoded, encoding: .utf8) {
            connectivity.send(["workout": jsonString])
        }
    }


}
