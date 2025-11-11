//
//  WorkoutView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject var viewModel = WorkoutViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("🏃 Run")
                .font(.title3).bold()

            VStack(alignment: .leading, spacing: 6) {
                Text("❤️ Heart rate: \(Int(viewModel.heartRate)) bpm")
                Text("📏 Distance: \((viewModel.distance / 1000).formatted(.number.precision(.fractionLength(2)))) km")
                Text("🔥 Calories: \(Int(viewModel.calories)) kcal")
                Text("⏱ Pace: \(viewModel.pace, specifier: "%.2f") s/m")
            }

            HStack(spacing: 12) {
                if !viewModel.isRunning {
                    Button("Start") { viewModel.startWorkout() }
                        .buttonStyle(.borderedProminent)
                } else if viewModel.isPaused {
                    Button("Resume") { viewModel.resumeWorkout() }
                        .buttonStyle(.borderedProminent)
                    Button("End") { viewModel.endWorkout() }
                        .buttonStyle(.bordered).tint(.red)
                } else {
                    Button("Pause") { viewModel.pauseWorkout() }
                        .buttonStyle(.bordered)
                    Button("End") { viewModel.endWorkout() }
                        .buttonStyle(.bordered).tint(.red)
                }
            }
        }
        .padding()
    }
}
