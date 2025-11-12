//
//  WorkoutView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var vm = WatchWorkoutViewModel()
    
    var body: some View {
        VStack(spacing: 6) {
            if vm.isRunning {
                Text("🏃 Running...")
                Text("❤️ HR: \(vm.heartRate, specifier: "%.0f") bpm")
                Text("📏 Distance: \(vm.distance, specifier: "%.1f") m")
                Text("🔥 Calories: \(vm.calories, specifier: "%.0f") kcal")
                
                HStack {
                    Button("Pause") { vm.pauseWorkout() }
                    Button("End") { vm.endWorkout() }
                }
            } else {
                Text("Waiting for iPhone...")
            }
        }
        .padding()
    }
}
