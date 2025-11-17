//
//  StrengthTrainingViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 17/11/25.
//

import Foundation
import CoreMotion
import Combine

@MainActor
class StrengthTrainingViewModel: ObservableObject {
    private let motion = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var repCount = 0
    @Published var lastRepDuration: TimeInterval = 0
    @Published var avgRepSpeed: Double = 0
    @Published var currentExercise: ExerciseType? = nil
    
    private var lastPeakTime: Date?
    private var lastAcc: Double = 0
    private var speeds: [Double] = []
    
    enum ExerciseType: String {
        case benchPress = "Bench Press"
        case shoulderPress = "Shoulder Press"
    }
    
    private var upThreshold: Double = 1.2
    private var downThreshold: Double = -0.8
    
    func selectExercise(_ exercise: ExerciseType) {
        currentExercise = exercise
        switch exercise {
        case .benchPress:
            upThreshold = 1.2
            downThreshold = -0.8
        case .shoulderPress:
            upThreshold = 1.0
            downThreshold = -0.7
        }
        reset()
    }
    
    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        
        motion.deviceMotionUpdateInterval = 1.0 / 50.0
        motion.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            self.process(data)
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
    }
    
    private func reset() {
        repCount = 0
        lastRepDuration = 0
        avgRepSpeed = 0
        speeds.removeAll()
        lastPeakTime = nil
        lastAcc = 0
    }
    
    private func process(_ data: CMDeviceMotion) {
        guard currentExercise != nil else { return }
        
        // Z-axis acceleration (assuming phone is held horizontally)
        let acc = data.userAcceleration.z + data.gravity.z
        
        // Peak detection
        if acc > upThreshold && lastAcc <= upThreshold {
            lastPeakTime = Date()
        } else if acc < downThreshold, let last = lastPeakTime {
            // Rep completed
            let now = Date()
            let duration = now.timeIntervalSince(last)
            lastRepDuration = duration
            repCount += 1
            
            // Calculate speed (rep per minute)
            let speed = 1.0 / duration * 60
            speeds.append(speed)
            avgRepSpeed = speeds.reduce(0,+)/Double(speeds.count)
            
            lastPeakTime = nil
        }
        
        lastAcc = acc
    }
}
