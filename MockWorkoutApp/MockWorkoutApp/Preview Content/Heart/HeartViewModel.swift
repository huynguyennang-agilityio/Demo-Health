import Foundation
import HealthKit

@MainActor
final class HeartViewModel: ObservableObject {
    @Published var samples: [HeartSample] = []
    @Published var errorMessage: String?

    private let manager = HeartManager()

    // MARK: - Authorization
    func requestAuthorization() async {
        await manager.requestAuthorization()
        self.errorMessage = manager.errorMessage
    }

    // MARK: - Fetch HRV for a specific date
    func fetchHRV(forFixedDate date: Date = HeartViewModel.defaultDate()) async {
        samples.removeAll()
        errorMessage = nil

        await manager.fetchHRV(for: date)
        self.errorMessage = manager.errorMessage

        self.samples = manager.samples.map { HeartSample(date: $0.date, hrvMs: $0.hrvMs) }
    }

    // Default date cũ
    nonisolated static func defaultDate() -> Date {
        var components = DateComponents()
        components.year = 2023
        components.month = 1
        components.day = 23
        return Calendar.current.date(from: components)!
    }
}
