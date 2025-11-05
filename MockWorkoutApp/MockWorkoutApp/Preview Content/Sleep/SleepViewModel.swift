//
//  SleepViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 5/11/25.
//

import Foundation

@MainActor
final class SleepViewModel: ObservableObject {
    @Published var sleeps: [DailySleepSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let sleepManager = SleepManager()

    func loadSleepData() async {
        isLoading = true
        errorMessage = nil
        do {
            try await sleepManager.requestAuthorization()
            let data = try await sleepManager.fetchSleepData(forLast: 14)
            sleeps = data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
