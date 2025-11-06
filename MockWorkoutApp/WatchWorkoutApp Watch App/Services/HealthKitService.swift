//
//  HealthKitService.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import HealthKit

final class HealthKitService: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var heartRate = 0.0
    @Published var distance = 0.0
    @Published var calories = 0.0
    @Published var pace = 0.0
    @Published var isRunning = false
    @Published var isPaused = false

    func requestAuthorization() async {
        let toShare: Set = [HKObjectType.workoutType()]
        let toRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        try? await healthStore.requestAuthorization(toShare: toShare, read: toRead)
    }

    func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            session?.delegate = self
            builder?.delegate = self

            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { _, _ in }

            isRunning = true
        } catch {
            print("❌ Failed to start workout: \(error)")
        }
    }

    func pause() {
        try? healthStore.pause(session!)
        isPaused = true
    }

    func resume() {
        try? healthStore.resumeWorkoutSession(session!)
        isPaused = false
    }

    func end() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in
            self.builder?.finishWorkout { _, _ in }
        }
        isRunning = false
        isPaused = false
    }

    // MARK: - Delegate Updates
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        for type in types {
            guard let quantityType = type as? HKQuantityType else { continue }
            let stats = workoutBuilder.statistics(for: quantityType)

            switch quantityType.identifier {
            case HKQuantityTypeIdentifier.heartRate.rawValue:
                heartRate = stats?.mostRecentQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                calories = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
                distance = stats?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                let time = workoutBuilder.elapsedTime
                pace = distance > 0 ? (time / distance) : 0
            default:
                break
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
