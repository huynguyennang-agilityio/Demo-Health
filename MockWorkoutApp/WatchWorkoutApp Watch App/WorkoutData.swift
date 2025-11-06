//
//  WorkoutData.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation

struct WorkoutData: Codable {
    var heartRate: Double
    var distance: Double
    var calories: Double
    var pace: Double
    var timestamp: Date
}
