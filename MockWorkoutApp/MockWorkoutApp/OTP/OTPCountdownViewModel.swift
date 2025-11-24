//
//  OTPCountdownViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 24/11/25.
//

import SwiftUI
import Combine

// MARK: - ViewModel
final class OTPTimelineViewModel: ObservableObject {

    // Published properties for UI updates
    @Published var endDate: Date = Date().addingTimeInterval(30)
    @Published var isLoading: Bool = false       // Loading state for API call
    @Published var errorMessage: String? = nil   // Optional error message

    let countdownSeconds: Int = 30

    // Reset countdown timer
    func resetCountdown() {
        endDate = Date().addingTimeInterval(TimeInterval(countdownSeconds))
    }

    // Calculate remaining seconds from a specific date
    func remainingSeconds(from date: Date) -> Int {
        max(Int(endDate.timeIntervalSince(date)), 0)
    }

    // Check if countdown is finished
    var isExpired: Bool {
        remainingSeconds(from: Date()) == 0
    }

    // MARK: - API Call using async/await
    func resendCode() async {
        // Avoid multiple API calls
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Simulate real API call delay
            try await Task.sleep(nanoseconds: 1_200_000_000)

            // --- Place your real API logic here ---
            // let success = try await api.resendOTP()
            // --------------------------------------

            // If API succeeded, reset timer
            await MainActor.run {
                resetCountdown()
            }

        } catch {
            // Handle API error
            await MainActor.run {
                errorMessage = "Failed to resend code."
            }
        }

        // Done loading
        await MainActor.run {
            isLoading = false
        }
    }
}


