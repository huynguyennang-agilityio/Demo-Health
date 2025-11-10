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

    // Formatter hiển thị ngày
    private let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df
    }()

    // Formatter hiển thị ngày + giờ + phút + giây
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
                } else if viewModel.samples.isEmpty {
                    Text("Loading HRV for \(dayFormatter.string(from: HeartViewModel.defaultDate())) ...")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(viewModel.samples) { sample in
                        HStack {
                            Text(fullDateFormatter.string(from: sample.date))
                                .font(.system(.body, design: .monospaced)) // hiển thị đều cột giờ
                            Spacer()
                            Text("\(String(format: "%.1f", sample.hrvMs)) ms")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("HRV Details")
            .task {
                await viewModel.requestAuthorization()
                await viewModel.fetchHRV(forFixedDate: HeartViewModel.defaultDate())
            }
        }
    }
}
