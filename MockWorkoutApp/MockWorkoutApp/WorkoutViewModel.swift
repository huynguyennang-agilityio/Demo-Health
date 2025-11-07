//
//  WorkoutViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 6/11/25.
//

import Foundation
import Combine

@MainActor
final class WorkoutViewModel: ObservableObject {
    private let connectivity = iOSConnectivityService.shared
    @Published var latestData: WorkoutData?

    init() {
        observeWorkoutData()
    }

    private func observeWorkoutData() {
        Task { [weak self] in
            guard let self = self else { return }

            for await data in self.connectivity.$latestData.values {
                await MainActor.run {
                    self.latestData = data
                }
            }
        }
    }

    func sendCommand(_ command: String) {
        connectivity.sendCommand(command)
    }
}
