import Foundation
import HealthKit

@MainActor
final class HeartViewModel: ObservableObject {
    @Published var hrvSamples: [HeartSample] = []
    @Published var rhrSamples: [HeartSample] = []
    @Published var errorMessage: String?

    private let manager = HeartManager()

    // MARK: - Authorization
    func requestAuthorization() async {
        await manager.requestAuthorization()
        self.errorMessage = manager.errorMessage
    }

    // MARK: - Fetch HRV for a specific date
    func fetchHearts(forFixedDate date: Date = HeartViewModel.defaultDate()) async {
        hrvSamples.removeAll()
        errorMessage = nil

        await manager.fetchHeartData(for: date)
        self.errorMessage = manager.errorMessage

        self.hrvSamples = manager.hrvSamples.map { HeartSample(date: $0.date, hrvMs: $0.hrvMs) }
        
        self.rhrSamples = manager.rhrSamples.map { HeartSample(date: $0.date, hrvMs: $0.bpm) }

    }

    nonisolated static func defaultDate() -> Date {
        var components = DateComponents()
        components.year = 2023
        components.month = 1
        components.day = 23
        return Calendar.current.date(from: components)!
    }
}
