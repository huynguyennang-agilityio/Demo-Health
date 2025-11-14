//
//  RunningViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 14/11/25.
//

import Foundation
import CoreMotion
import Combine

@MainActor
class RunningViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var steps: Int = 0
    @Published var distance: Double = 0      // meters
    @Published var pace: Double = 0          // m/s
    
    private let motionActivity = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var startDate: Date?
    
    func startMonitoring() {
        startDate = Date()
        
        // 1️⃣ Detect activity type
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivity.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self = self, let activity = activity else { return }
                self.isRunning = activity.running && !activity.automotive && !activity.cycling
            }
        }
        
        // 2️⃣ Track steps/distance
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else { return }
                Task { @MainActor in
                    self.steps = data.numberOfSteps.intValue
                    self.distance = data.distance?.doubleValue ?? 0
                    
                    // Calculate pace = distance / elapsed time
                    if let start = self.startDate {
                        let elapsed = Date().timeIntervalSince(start) // seconds
                        if elapsed > 0 {
                            self.pace = self.distance / elapsed   // m/s
                        }
                    }
                }
            }
        }
    }
    
    func stopMonitoring() {
        motionActivity.stopActivityUpdates()
        pedometer.stopUpdates()
        isRunning = false
        pace = 0
    }
}
