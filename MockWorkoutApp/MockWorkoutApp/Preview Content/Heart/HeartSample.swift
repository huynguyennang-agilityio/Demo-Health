//
//  HeartSample.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 10/11/25.
//

import Foundation

struct HeartSample: Identifiable {
    let id = UUID()
    let date: Date
    let hrvMs: Double
}
