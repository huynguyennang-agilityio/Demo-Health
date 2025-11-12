//
//  WorkoutAttributes.swift
//  Share
//
//  Created by nanghuy on 12/11/25.
//

import ActivityKit
import Foundation

public struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var heartRate: Double
        var distance: Double
        var calories: Double
        var pace: Double
    }
    
    public var activityType: String = "Running"
}
