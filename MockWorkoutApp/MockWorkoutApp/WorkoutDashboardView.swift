//
//  WorkoutDashboardView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI
import SwiftUI

struct WorkoutDashboardView: View {
    @StateObject private var vm = WorkoutViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            Text(vm.isRunning ? "🏃 Running..." : "Press Start")
            Text("❤️ HR: \(vm.heartRate, specifier: "%.0f") bpm")
            Text("📏 Distance: \(vm.distance, specifier: "%.1f") m")
            Text("🔥 Calories: \(vm.calories, specifier: "%.0f") kcal")
            Text("⚡ Pace: \(vm.pace, specifier: "%.2f") m/s")

            HStack {
                Button("Start") { vm.startWorkout() }
                Button("Pause") { vm.pauseWorkout() }
                Button("Resume") { vm.resumeWorkout() }
                Button("End") { vm.endWorkout() }
            }
        }
        .padding()
    }
}
