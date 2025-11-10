import Foundation
import HealthKit

@MainActor
final class HeartManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var samples: [(date: Date, hrvMs: Double)] = []
    @Published var errorMessage: String?

    // MARK: - Authorization
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data not available on this device."
            return
        }
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            errorMessage = "HRV type unavailable."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [hrvType])
        } catch {
            errorMessage = "Authorization failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch HRV for a specific date
    func fetchHRV(for date: Date) async {
        samples.removeAll()
        errorMessage = nil

        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            errorMessage = "HRV type unavailable."
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        do {
            let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
                let query = HKSampleQuery(
                    sampleType: hrvType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
                }
                healthStore.execute(query)
            }

            let unit = HKUnit.secondUnit(with: .milli)
            self.samples = results.map { ($0.endDate, $0.quantity.doubleValue(for: unit)) }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for s in self.samples {
                let dateString = formatter.string(from: s.date)
                print("\(dateString): \(s.hrvMs) ms")
            }

        } catch {
            self.errorMessage = "Fetch error: \(error.localizedDescription)"
            print(self.errorMessage!)
        }
    }
}
