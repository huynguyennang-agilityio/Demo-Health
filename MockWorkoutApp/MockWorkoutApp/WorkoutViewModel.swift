//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import Combine
import Share

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var calories: Double = 0
    @Published var pace: Double = 0
    @Published var isRunning: Bool = false
    
    private let connectivity = WatchConnectivityService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("Config.shared.baseURL: \(Config.shared.baseURL)")
        connectivity.$latestData
            .compactMap { $0 }
            .sink { [weak self] data in
                guard let self = self else { return }
                self.heartRate = data.heartRate
                self.distance = data.distance
                self.calories = data.calories
                self.pace = data.pace
            }
            .store(in: &cancellables)
    }
    
    func startWorkout() {
        connectivity.sendCommand("startWorkout")
        isRunning = true
    }
    
    func pauseWorkout() { connectivity.sendCommand("pauseWorkout") }
    func resumeWorkout() { connectivity.sendCommand("resumeWorkout") }
    func endWorkout() {
        connectivity.sendCommand("endWorkout")
        isRunning = false
    }
}
