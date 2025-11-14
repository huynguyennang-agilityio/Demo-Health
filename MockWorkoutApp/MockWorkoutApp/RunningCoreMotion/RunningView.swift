//
//  RunningView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 14/11/25.
//

import SwiftUI

struct RunningView: View {
    @StateObject private var vm = RunningViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Running: \(vm.isRunning ? "✅ Yes" : "❌ No")")
                .font(.title)
                .bold()
            
            Text("Steps: \(vm.steps)")
            Text("Distance: \(vm.distance, specifier: "%.1f") m")
            Text("Pace: \(vm.pace, specifier: "%.2f") m/s")
            
            HStack {
                Button("Start") { vm.startMonitoring() }
                    .padding()
                    .background(.green.opacity(0.7))
                    .cornerRadius(8)
                Button("Stop") { vm.stopMonitoring() }
                    .padding()
                    .background(.red.opacity(0.7))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
