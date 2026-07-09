import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    nonisolated(unsafe) private let foodLogEntryRepository: any FoodLogEntryRepository
    nonisolated(unsafe) private let exerciseLogEntryRepository: any ExerciseLogEntryRepository
    nonisolated(unsafe) private let biometricsEntryRepository: any BiometricsEntryRepository
    private let dateProvider: () -> Date

    @Published var selectedDate: Date
    @Published private(set) var summary: DailySummary
    @Published private(set) var isLoading = false
    @Published private(set) var hasLoaded = false
    @Published var errorMessage: String?

    init(
        foodLogEntryRepository: any FoodLogEntryRepository,
        exerciseLogEntryRepository: any ExerciseLogEntryRepository,
        biometricsEntryRepository: any BiometricsEntryRepository,
        selectedDate: Date? = nil,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.foodLogEntryRepository = foodLogEntryRepository
        self.exerciseLogEntryRepository = exerciseLogEntryRepository
        self.biometricsEntryRepository = biometricsEntryRepository
        self.dateProvider = dateProvider

        let initialDate = selectedDate ?? dateProvider()
        self.selectedDate = initialDate
        summary = DailySummary(date: initialDate)
    }

    convenience init(environment: AppEnvironment, dateProvider: @escaping () -> Date = Date.init) {
        self.init(
            foodLogEntryRepository: environment.foodLogEntryRepository,
            exerciseLogEntryRepository: environment.exerciseLogEntryRepository,
            biometricsEntryRepository: environment.biometricsEntryRepository,
            dateProvider: dateProvider
        )
    }

    var mealSummaryLines: [String] {
        guard !summary.foodLogEntries.isEmpty else {
            return ["No recent food entries"]
        }

        var lines = ["\(summary.foodLogEntries.count) \(entryText(summary.foodLogEntries.count, singular: "food entry", plural: "food entries")) logged"]

        if let calories = summary.nutritionTotals.calories {
            lines.append("\(formatted(calories.value)) calories logged")
        }

        let macroLines = [
            summary.nutritionTotals.protein.map { "\(formatted($0.value))g protein" },
            summary.nutritionTotals.carbohydrates.map { "\(formatted($0.value))g carbohydrates" },
            summary.nutritionTotals.fat.map { "\(formatted($0.value))g fat" }
        ].compactMap { $0 }

        if !macroLines.isEmpty {
            lines.append(macroLines.joined(separator: " · "))
        }

        return lines
    }

    var exerciseSummaryLines: [String] {
        guard !summary.exerciseLogEntries.isEmpty else {
            return ["No recent exercise entries"]
        }

        var lines = ["\(summary.exerciseLogEntries.count) \(entryText(summary.exerciseLogEntries.count, singular: "exercise entry", plural: "exercise entries")) logged"]
        let duration = summary.exerciseEstimateTotals.duration.value
        if duration > 0 {
            lines.append("\(formatted(duration)) minutes logged")
        }

        let calories = summary.exerciseEstimateTotals.caloriesBurned.value
        if calories > 0 {
            lines.append("\(formatted(calories)) estimated calories")
        }

        return lines
    }

    var biometricsSummaryLines: [String] {
        guard !summary.biometricEntries.isEmpty else {
            return ["No recent biometrics entries"]
        }

        var lines = ["\(summary.biometricEntries.count) \(entryText(summary.biometricEntries.count, singular: "biometric entry", plural: "biometric entries")) logged"]
        if let recentEntry = summary.biometricEntries.first {
            lines.append("\(recentEntry.kind.displayName): \(formatted(recentEntry.value))")
        }

        return lines
    }

    func loadSummary() async {
        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let foodEntries = try await foodLogEntryRepository.listEntries(for: selectedDate)
            let exerciseEntries = try await exerciseLogEntryRepository.listEntries(for: selectedDate)
            let biometricEntries = try await biometricsEntryRepository.listEntries(for: selectedDate)

            summary = DailySummary(
                date: selectedDate,
                foodLogEntries: foodEntries,
                exerciseLogEntries: exerciseEntries,
                biometricEntries: biometricEntries
            )
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            errorMessage = TodayViewError.load.localizedDescription
        }
    }

    func refresh() async {
        selectedDate = dateProvider()
        await loadSummary()
    }

    private func entryText(_ count: Int, singular: String, plural: String) -> String {
        count == 1 ? singular : plural
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

private enum TodayViewError: LocalizedError {
    case load

    var errorDescription: String? {
        switch self {
        case .load:
            return "We couldn't load the summary. Please try again."
        }
    }
}

extension BiometricsKind {
    var displayName: String {
        switch self {
        case .weight:
            return "Weight"
        case .systolicBloodPressure:
            return "Systolic blood pressure"
        case .diastolicBloodPressure:
            return "Diastolic blood pressure"
        case .restingHeartRate:
            return "Resting heart rate"
        case .waistMeasurement:
            return "Waist measurement"
        }
    }

    var unitLabel: String {
        switch self {
        case .weight:
            return "lb"
        case .systolicBloodPressure, .diastolicBloodPressure:
            return "mmHg"
        case .restingHeartRate:
            return "bpm"
        case .waistMeasurement:
            return "in"
        }
    }
}
