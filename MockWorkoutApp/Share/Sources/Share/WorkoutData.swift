//
//  WorkoutData.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 11/11/25.
//

import Foundation

public struct WorkoutData: Codable {
    public let heartRate: Double
    public let distance: Double
    public let calories: Double
    public let pace: Double
    public let timestamp: Date
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.heartRate = try container.decode(Double.self, forKey: .heartRate)
        self.distance = try container.decode(Double.self, forKey: .distance)
        self.calories = try container.decode(Double.self, forKey: .calories)
        self.pace = try container.decode(Double.self, forKey: .pace)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    public init(heartRate: Double,
         distance: Double,
         calories: Double,
         pace: Double,
         timestamp: Date) {
        self.heartRate = heartRate
        self.distance = distance
        self.calories = calories
        self.pace = pace
        self.timestamp = timestamp
    }
}
