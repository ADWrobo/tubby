import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct TodayFeatureTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)

    @MainActor
    @Test func emptyRepositoriesProduceEmptySummaryText() async {
        let viewModel = makeViewModel()

        await viewModel.loadSummary()

        #expect(viewModel.mealSummaryLines == ["No recent food entries"])
        #expect(viewModel.exerciseSummaryLines == ["No recent exercise entries"])
        #expect(viewModel.biometricsSummaryLines == ["No recent biometrics entries"])
        #expect(viewModel.errorMessage == nil)
    }

    @MainActor
    @Test func foodEntriesProduceCountAndNutritionTotals() async throws {
        let foodRepository = InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar)
        _ = try await foodRepository.save(
            makeFoodEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005001")!,
                calories: 150,
                protein: 10,
                carbohydrates: 20,
                fat: 5,
                servings: 2
            )
        )
        _ = try await foodRepository.save(
            makeFoodEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005002")!,
                calories: 200,
                protein: 12,
                carbohydrates: 30,
                fat: 8,
                servings: 1
            )
        )
        let viewModel = makeViewModel(foodRepository: foodRepository)

        await viewModel.loadSummary()

        #expect(viewModel.summary.foodLogEntries.count == 2)
        #expect(viewModel.summary.nutritionTotals.calories == Calories(500))
        #expect(viewModel.summary.nutritionTotals.protein == Grams(32))
        #expect(viewModel.summary.nutritionTotals.carbohydrates == Grams(70))
        #expect(viewModel.summary.nutritionTotals.fat == Grams(18))
        #expect(viewModel.mealSummaryLines == [
            "2 food entries logged",
            "500 calories logged",
            "32g protein · 70g carbohydrates · 18g fat"
        ])
    }

    @MainActor
    @Test func exerciseEntriesProduceCountDurationAndEstimatedCalories() async throws {
        let exerciseRepository = InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar)
        _ = try await exerciseRepository.save(
            makeExerciseEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005101")!,
                duration: 30,
                caloriesBurnedPerMinute: 4
            )
        )
        _ = try await exerciseRepository.save(
            makeExerciseEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005102")!,
                duration: 20,
                caloriesBurnedPerMinute: 5
            )
        )
        let viewModel = makeViewModel(exerciseRepository: exerciseRepository)

        await viewModel.loadSummary()

        #expect(viewModel.summary.exerciseLogEntries.count == 2)
        #expect(viewModel.summary.exerciseEstimateTotals.duration == Minutes(50))
        #expect(viewModel.summary.exerciseEstimateTotals.caloriesBurned == Calories(220))
        #expect(viewModel.exerciseSummaryLines == [
            "2 exercise entries logged",
            "50 minutes logged",
            "220 estimated calories"
        ])
    }

    @MainActor
    @Test func biometricEntriesProduceCountAndRecentDetail() async throws {
        let biometricsRepository = InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar)
        _ = try await biometricsRepository.save(
            makeBiometricsEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005201")!,
                loggedAt: Self.day.addingTimeInterval(60),
                kind: .weight,
                value: 180
            )
        )
        _ = try await biometricsRepository.save(
            makeBiometricsEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005202")!,
                loggedAt: Self.day.addingTimeInterval(120),
                kind: .restingHeartRate,
                value: 62
            )
        )
        let viewModel = makeViewModel(biometricsRepository: biometricsRepository)

        await viewModel.loadSummary()

        #expect(viewModel.summary.biometricEntries.count == 2)
        #expect(viewModel.biometricsSummaryLines == [
            "2 biometric entries logged",
            "Resting heart rate: 62"
        ])
    }

    @MainActor
    @Test func repositoryLoadErrorsBecomeCalmUserFacingText() async {
        let viewModel = TodayViewModel(
            foodLogEntryRepository: FailingFoodLogEntryRepository(),
            exerciseLogEntryRepository: InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar),
            biometricsEntryRepository: InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar),
            selectedDate: Self.day
        )

        await viewModel.loadSummary()

        #expect(viewModel.errorMessage == "We couldn't load the summary. Please try again.")
        #expect(viewModel.mealSummaryLines == ["No recent food entries"])
    }

    @MainActor
    @Test func refreshReloadsRepositoryDataAfterChanges() async throws {
        let foodRepository = InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar)
        let viewModel = makeViewModel(foodRepository: foodRepository)

        await viewModel.loadSummary()
        #expect(viewModel.summary.foodLogEntries.isEmpty)

        _ = try await foodRepository.save(
            makeFoodEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005301")!,
                calories: 450,
                protein: 25,
                carbohydrates: 40,
                fat: 16,
                servings: 1
            )
        )

        await viewModel.refresh()

        #expect(viewModel.summary.foodLogEntries.count == 1)
        #expect(viewModel.mealSummaryLines.contains("450 calories logged"))
    }

    @MainActor
    private func makeViewModel(
        foodRepository: (any FoodLogEntryRepository)? = nil,
        exerciseRepository: (any ExerciseLogEntryRepository)? = nil,
        biometricsRepository: (any BiometricsEntryRepository)? = nil
    ) -> TodayViewModel {
        TodayViewModel(
            foodLogEntryRepository: foodRepository ?? InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar),
            exerciseLogEntryRepository: exerciseRepository ?? InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar),
            biometricsEntryRepository: biometricsRepository ?? InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar),
            selectedDate: Self.day,
            dateProvider: { Self.day }
        )
    }

    private func makeFoodEntry(
        id: UUID,
        calories: Double,
        protein: Double,
        carbohydrates: Double,
        fat: Double,
        servings: Double
    ) -> FoodLogEntry {
        FoodLogEntry(
            id: id,
            loggedAt: Self.day,
            mealType: .lunch,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005401")!,
                name: "Lunch",
                nutritionFacts: NutritionFacts(
                    calories: Calories(calories),
                    protein: Grams(protein),
                    carbohydrates: Grams(carbohydrates),
                    fat: Grams(fat)
                )
            ),
            servings: servings
        )
    }

    private func makeExerciseEntry(
        id: UUID,
        duration: Double,
        caloriesBurnedPerMinute: Double
    ) -> ExerciseLogEntry {
        ExerciseLogEntry(
            id: id,
            loggedAt: Self.day,
            activity: ExerciseActivity(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005501")!,
                name: "Walking",
                caloriesBurnedPerMinute: Calories(caloriesBurnedPerMinute)
            ),
            duration: Minutes(duration),
            intensity: .moderate
        )
    }

    private func makeBiometricsEntry(
        id: UUID,
        loggedAt: Date,
        kind: BiometricsKind,
        value: Double
    ) -> BiometricsEntry {
        BiometricsEntry(
            id: id,
            loggedAt: loggedAt,
            value: value,
            kind: kind
        )
    }
}

private struct FailingFoodLogEntryRepository: FoodLogEntryRepository {
    func listRecentEntries(limit: Int) async throws -> [FoodLogEntry] {
        throw TestRepositoryError.load
    }

    func listEntries(for date: Date) async throws -> [FoodLogEntry] {
        throw TestRepositoryError.load
    }

    func listEntries(from startDate: Date, through endDate: Date) async throws -> [FoodLogEntry] {
        throw TestRepositoryError.load
    }

    func save(_ entry: FoodLogEntry) async throws -> FoodLogEntry {
        throw TestRepositoryError.load
    }

    func delete(id: FoodLogEntry.ID) async throws {
        throw TestRepositoryError.load
    }
}

private enum TestRepositoryError: Error {
    case load
}
