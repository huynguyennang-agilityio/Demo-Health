//
//  WorkoutDashboardView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WorkoutDashboardView: View {
    @StateObject var viewModel = WorkoutViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("📊 Running Dashboard")
                .font(.title2)
                .bold()

            if let data = viewModel.latestData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("❤️ Heart rate: \(Int(data.heartRate)) bpm")
                    Text("📏 Distance: \((data.distance / 1000).formatted(.number.precision(.fractionLength(2)))) km")
                    Text("🔥 Calories: \(Int(data.calories)) kcal")
                    Text("⏱ Pace: \(data.pace, specifier: "%.2f") s/m")
                }
                .font(.headline)
                .padding()
            } else {
                Text("Waiting for Watch data...")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
