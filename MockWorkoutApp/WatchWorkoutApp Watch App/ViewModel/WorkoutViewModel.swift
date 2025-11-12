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
import Share

@MainActor
final class WatchWorkoutViewModel: ObservableObject {
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var calories: Double = 0
    @Published var pace: Double = 0
    @Published var isRunning: Bool = false
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var cancellables = Set<AnyCancellable>()
    
    private let connectivity = WatchConnectivityService.shared
//    private var liveActivity: Activity<WorkoutAttributes>?
    
    init() {
        connectivity.onCommandReceived = { [weak self] cmd in
            guard let self = self else { return }
            switch cmd {
            case "startWorkout": Task { await self.startWorkout() }
            case "pauseWorkout": self.pauseWorkout()
            case "resumeWorkout": self.resumeWorkout()
            case "endWorkout": self.endWorkout()
            default: break
            }
        }
    }
    
    func startWorkout() async {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        do {
            try await healthStore.requestAuthorization(
                toShare: [HKObjectType.workoutType()],
                read: [
                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                    HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                ]
            )
            
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = workoutSession?.associatedWorkoutBuilder()
            workoutSession?.startActivity(with: .now)
            isRunning = true
            startLiveActivity()
            subscribeBuilder()
        } catch {
            print("❌ Watch workout failed: \(error)")
        }
    }
    
    private func subscribeBuilder() {
        guard let builder = builder else { return }
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: builder.workoutConfiguration)
        builder.beginCollection(withStart: Date()) { success, error in
            if let error = error { print("Builder collection error: \(error)") }
        }
        
        builder.publisher(for: \.statistics)
            .sink { stats in
                if let hr = stats[HKQuantityType.quantityType(forIdentifier: .heartRate)!]?.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) {
                    self.heartRate = hr
                }
                if let dist = stats[HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!]?.sumQuantity()?.doubleValue(for: .meter()) {
                    self.distance = dist
                }
                if let kcal = stats[HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]?.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                    self.calories = kcal
                }
                
                let data = WorkoutData(heartRate: self.heartRate, distance: self.distance, calories: self.calories, pace: 0, timestamp: Date())
                self.connectivity.latestData = data
                if let json = try? JSONEncoder().encode(data),
                   let jsonString = String(data: json, encoding: .utf8),
                   WCSession.default.isReachable {
                    WCSession.default.sendMessage(["workout": jsonString], replyHandler: nil)
                }
                
                self.updateLiveActivity()
            }
            .store(in: &cancellables)
    }
    
    func pauseWorkout() { workoutSession?.pause() }
    func resumeWorkout() { workoutSession?.resume() }
    func endWorkout() {
        workoutSession?.end()
        isRunning = false
        endLiveActivity()
    }
    
    // MARK: Live Activity
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let initialState = WorkoutAttributes.ContentState(heartRate: heartRate, distance: distance, calories: calories, pace: pace)
        do {
            liveActivity = try Activity<WorkoutAttributes>.request(
                attributes: WorkoutAttributes(),
                contentState: initialState,
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }
    
    func updateLiveActivity() {
        guard let liveActivity = liveActivity else { return }
        let state = WorkoutAttributes.ContentState(heartRate: heartRate, distance: distance, calories: calories, pace: pace)
        Task { await liveActivity.update(using: state) }
    }
    
    func endLiveActivity() {
        Task { await liveActivity?.end(dismissalPolicy: .immediate) }
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
