//
//  HeartFixedDateView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 10/11/25.
//

import SwiftUI
import Combine

struct HeartDetailView: View {
    @StateObject private var viewModel = HeartViewModel()

    private let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df
    }()

    private let fullDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm:ss" // có thể thêm .SSS nếu muốn mili giây
        return df
    }()

    var body: some View {
        NavigationStack {
            VStack {
                if let error = viewModel.errorMessage {
                    Text("⚠️ \(error)").foregroundColor(.red)
                } else if viewModel.hrvSamples.isEmpty && viewModel.rhrSamples.isEmpty {
                    Text("Loading Hearts for \(dayFormatter.string(from: HeartViewModel.defaultDate())) ...")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    Text("HRV Detail")
                    List(viewModel.hrvSamples) { sample in
                        HStack {
                            Text(fullDateFormatter.string(from: sample.date))
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Text("\(String(format: "%.1f", sample.hrvMs)) ms")
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    Text("RHR Detail")
                    List(viewModel.rhrSamples) { sample in
                        HStack {
                            Text(fullDateFormatter.string(from: sample.date))
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Text("\(String(format: "%.1f", sample.hrvMs)) ms")
                        }
                    }
                    .listStyle(.insetGrouped)

                }
            }
            .navigationTitle("Heart Details")
            .task {
                await viewModel.requestAuthorization()
                await viewModel.fetchHearts(forFixedDate: HeartViewModel.defaultDate())
            }
        }
    }
}
