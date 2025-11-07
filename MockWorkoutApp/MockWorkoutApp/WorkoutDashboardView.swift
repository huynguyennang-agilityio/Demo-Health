//
//  WorkoutDashboardView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WorkoutDashboardView: View {
    @StateObject var viewModel = WorkoutViewModel()
    @State private var isRunning = false
    @State private var isPaused = false

    var body: some View {
        VStack(spacing: 20) {
            Text("📊 Running Dashboard")
                .font(.title2).bold()

            if let data = viewModel.latestData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("❤️ Heart rate: \(Int(data.heartRate)) bpm")
                    Text("📏 Distance: \((data.distance / 1000).formatted(.number.precision(.fractionLength(2)))) km")
                    Text("🔥 Calories: \(Int(data.calories)) kcal")
                    Text("⏱ Pace: \(data.pace, specifier: "%.2f") s/m")
                }
            } else {
                Text("Waiting for Watch data…")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 12) {
                if !isRunning {
                    Button("Start") {
                        viewModel.sendCommand("start")
                        isRunning = true
                    }
                    .buttonStyle(.borderedProminent)
                } else if isPaused {
                    Button("Resume") {
                        viewModel.sendCommand("resume")
                        isPaused = false
                    }
                    .buttonStyle(.borderedProminent)
                    Button("End") {
                        viewModel.sendCommand("end")
                        isRunning = false
                        isPaused = false
                    }
                    .buttonStyle(.bordered).tint(.red)
                } else {
                    Button("Pause") {
                        viewModel.sendCommand("pause")
                        isPaused = true
                    }
                    .buttonStyle(.bordered)
                    Button("End") {
                        viewModel.sendCommand("end")
                        isRunning = false
                        isPaused = false
                    }
                    .buttonStyle(.bordered).tint(.red)
                }
            }
        }
        .padding()
    }
}
