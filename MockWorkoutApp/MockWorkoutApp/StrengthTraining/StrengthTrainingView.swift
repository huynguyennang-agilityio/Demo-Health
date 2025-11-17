//
//  StrengthTrainingView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 17/11/25.
//

import SwiftUI

struct StrengthTrainingView: View {
    @StateObject private var vm = StrengthTrainingViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Current Exercise: \(vm.currentExercise?.rawValue ?? "None")")
                .font(.title2)
            
            HStack(spacing: 20) {
                Button("Bench Press") {
                    vm.selectExercise(.benchPress)
                    vm.start()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Shoulder Press") {
                    vm.selectExercise(.shoulderPress)
                    vm.start()
                }
                .buttonStyle(.borderedProminent)
            }
            
            VStack(spacing: 12) {
                Text("Reps: \(vm.repCount)")
                    .font(.largeTitle.bold())
                Text("Last rep duration: \(vm.lastRepDuration, specifier: "%.2f") s")
                Text("Avg rep speed: \(vm.avgRepSpeed, specifier: "%.1f") rep/min")
            }
            
            Button("Stop") {
                vm.stop()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
