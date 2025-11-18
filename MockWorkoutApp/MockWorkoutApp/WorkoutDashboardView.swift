//
//  WorkoutDashboardView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WorkoutDashboardView: View {
    @StateObject private var vm = WorkoutViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text(
                vm.isRunning
                    ? "🏃 Running..."
                    : (vm.watchStatus == .ready
                        ? "Ready"
                        : "Waiting for Apple Watch…")
            )
            .font(.headline)

            Text("❤️ HR: \(vm.heartRate, specifier: "%.0f") bpm")
            Text("📏 Distance: \(vm.distance, specifier: "%.1f") m")
            Text("🔥 Calories: \(vm.calories, specifier: "%.0f") kcal")
            Text("⚡ Pace: \(vm.pace, specifier: "%.2f") m/s")

            HStack {
                Button("Start") { vm.startWorkoutTapped() }
                Button("Pause") { vm.pauseWorkout() }
                Button("Resume") { vm.resumeWorkout() }
                Button("End") { vm.endWorkout() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .alert("Please open the Apple Watch app", isPresented: $vm.showWatchAlert) {
            Button("Cancel", role: .cancel) { /* just dismiss */ }
        } message: {
            Text("Open the app on your Apple Watch so it can start the workout.")
        }
        .onAppear {
            // Ensure the connectivity service is created early (if not already).
            _ = WatchConnectivityService.shared
        }
    }
}

