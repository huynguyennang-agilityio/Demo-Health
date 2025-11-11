import Foundation
import HealthKit

@MainActor
final class HeartManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var hrvSamples: [(date: Date, hrvMs: Double)] = []
    @Published var rhrSamples: [(date: Date, bpm: Double)] = []
    @Published var heartRateSamples: [(date: Date, bpm: Double)] = []
    @Published var errorMessage: String?

    // MARK: - Authorization
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data not available on this device."
            return
        }

        guard
            let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let rhrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
            let hrType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else {
            errorMessage = "Some HealthKit type unavailable."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [hrvType, rhrType, hrType])
        } catch {
            errorMessage = "Authorization failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Generic HealthKit fetch
    private func fetchQuantitySamples(
        typeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        for date: Date
    ) async throws -> [(date: Date, value: Double)] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            throw NSError(domain: "HealthKit", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Type unavailable"])
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let result = (samples as? [HKQuantitySample])?.map {
                    ($0.endDate, $0.quantity.doubleValue(for: unit))
                } ?? []
                continuation.resume(returning: result)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Fetch HRV
    func fetchHRV(for date: Date) async {
        do {
            self.hrvSamples = try await fetchQuantitySamples(
                typeIdentifier: .heartRateVariabilitySDNN,
                unit: HKUnit.secondUnit(with: .milli),
                for: date
            ).map { (date: $0.date, hrvMs: $0.value) }
        } catch {
            errorMessage = "Fetch HRV error: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch RHR
    func fetchRHR(for date: Date) async {
        do {
            self.rhrSamples = try await fetchQuantitySamples(
                typeIdentifier: .restingHeartRate,
                unit: HKUnit.count().unitDivided(by: HKUnit.minute()),
                for: date
            ).map { (date: $0.date, bpm: $0.value) }
        } catch {
            errorMessage = "Fetch RHR error: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Heart Rate
    func fetchHeartRate(for date: Date) async {
        do {
            self.heartRateSamples = try await fetchQuantitySamples(
                typeIdentifier: .heartRate,
                unit: HKUnit.count().unitDivided(by: HKUnit.minute()),
                for: date
            ).map { (date: $0.date, bpm: $0.value) }
        } catch {
            errorMessage = "Fetch Heart Rate error: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch all data
    func fetchHeartData(for date: Date) async {
        await fetchHRV(for: date)
        await fetchRHR(for: date)
        await fetchHeartRate(for: date)
    }

    // MARK: - Static default date
    nonisolated static func defaultDate() -> Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 10
        components.day = 22
        return Calendar.current.date(from: components)!
    }
}
