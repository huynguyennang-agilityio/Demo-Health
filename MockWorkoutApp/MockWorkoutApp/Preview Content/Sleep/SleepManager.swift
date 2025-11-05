//
//  SleepManager.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 5/11/25.
//

import HealthKit

struct DailySleepSummary: Identifiable {
    let id = UUID()
    let date: Date
    let totalSleepHours: Double
    let startDate: Date
    let endDate: Date
}

final class SleepManager {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
    }

    func fetchSleepData(forLast days: Int = 14, endDate: Date = Date()) async throws -> [DailySleepSummary] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2019
        components.month = 5
        components.day = 6
        components.hour = 12
        let targetDay = calendar.date(from: components)!

        let startDate = calendar.date(byAdding: .hour, value: -12, to: targetDay)!
        let endDate = calendar.date(byAdding: .hour, value: 36, to: targetDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let samples = (results as? [HKCategorySample])?
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue } ?? []

                let grouped = Dictionary(grouping: samples) { sample -> Date in
                    calendar.startOfDay(for: sample.endDate)
                }

                let summaries = grouped.compactMap { (date, daySamples) -> DailySleepSummary in
                    let total = daySamples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                    let start = daySamples.map(\.startDate).min() ?? date
                    let end = daySamples.map(\.endDate).max() ?? date
                    return DailySleepSummary(date: date,
                                             totalSleepHours: total / 3600,
                                             startDate: start,
                                             endDate: end)
                }.sorted { $0.date < $1.date }

                continuation.resume(returning: summaries)
            }

            self.healthStore.execute(query)
        }
    }
}
