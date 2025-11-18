//
//  WorkoutView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WatchWorkoutView: View {
    @StateObject private var vm = WatchWorkoutViewModel()

    var body: some View {
        VStack(spacing: 8) {

            Text(vm.workoutStarted ? "🏃 Running…" : "Open the app on iPhone to start")
                .font(.headline)

            if vm.workoutStarted {
                VStack(alignment: .leading, spacing: 4) {
                    Text("❤️ \(vm.heartRate, specifier: "%.0f") bpm")
                    Text("🔥 \(vm.calories, specifier: "%.0f") kcal")
                    Text("📏 \(vm.distance, specifier: "%.1f") m")
                    Text("⚡ Pace: \(vm.pace, specifier: "%.2f") m/s")
                }
                .font(.system(size: 14))
            }
        }
        .padding()
        .onAppear {
            vm.notifyPhoneReady()
        }
    }
}
