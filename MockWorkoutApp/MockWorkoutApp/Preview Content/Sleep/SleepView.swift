//
//  SleepView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 5/11/25.
//

import SwiftUI
import Charts

struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading sleep data...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if #available(iOS 16.0, *) {
                        Chart(viewModel.sleeps) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Hours", item.totalSleepHours)
                            )
                            .annotation(position: .top) {
                                Text("\(String(format: "%.1f", item.totalSleepHours))h")
                                    .font(.caption)
                            }
                        }
                        .frame(height: 250)
                        .padding()
                    }
                    
                    List(viewModel.sleeps) { day in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(day.date, style: .date)
                                .font(.headline)
                            Text("Sleep: \(String(format: "%.1f", day.totalSleepHours)) hours")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("From \(day.startDate.formatted(date: .omitted, time: .shortened)) → \(day.endDate.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Sleep Summary")
            .task {
                await viewModel.loadSleepData()
            }
        }
    }
}

#Preview {
    SleepView()
}
