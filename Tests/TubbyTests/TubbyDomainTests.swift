import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct TubbyDomainTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)
    private static let nextDay = Date(timeIntervalSince1970: 1_700_086_400)

    @Test func nutritionTotalsScaleAndSum() {
        let item = FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            name: "Oatmeal",
            nutritionFacts: NutritionFacts(
                calories: Calories(150),
                protein: Grams(5),
                carbohydrates: Grams(27),
                fat: Grams(3),
                fiber: Grams(4),
                sodium: Milligrams(120)
            )
        )
        let entry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
            loggedAt: Self.day,
            mealType: .breakfast,
            foodItem: item,
            servings: 1.5
        )

        let totals = entry.nutritionFacts()

        #expect(totals.calories == Calories(225))
        #expect(totals.protein == Grams(7.5))
        #expect(totals.carbohydrates == Grams(40.5))
        #expect(totals.fat == Grams(4.5))
        #expect(totals.fiber == Grams(6))
        #expect(totals.sodium == Milligrams(180))
    }

    @Test func exerciseCaloriesUseDurationAndRate() {
        let activity = ExerciseActivity(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!,
            name: "Walking",
            caloriesBurnedPerMinute: Calories(4)
        )
        let entry = ExerciseLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!,
            loggedAt: Self.day,
            activity: activity,
            duration: Minutes(30),
            intensity: .moderate
        )

        #expect(entry.estimatedCaloriesBurned() == Calories(120))
    }

    @Test func dailySummaryAggregatesEntries() {
        let foodItem = FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000401")!,
            name: "Banana",
            nutritionFacts: NutritionFacts(calories: Calories(100), carbohydrates: Grams(25))
        )
        let foodEntry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000402")!,
            loggedAt: Self.day,
            mealType: .snack,
            foodItem: foodItem,
            servings: 2
        )
        let activity = ExerciseActivity(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000403")!,
            name: "Cycling",
            caloriesBurnedPerMinute: Calories(6)
        )
        let exerciseEntry = ExerciseLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000404")!,
            loggedAt: Self.day,
            activity: activity,
            duration: Minutes(20),
            intensity: .vigorous
        )
        let biometricEntry = BiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000405")!,
            loggedAt: Self.day,
            value: 180,
            kind: .weight
        )

        let summary = DailySummary(
            date: Self.day,
            foodLogEntries: [foodEntry],
            exerciseLogEntries: [exerciseEntry],
            biometricEntries: [biometricEntry]
        )

        #expect(summary.foodLogEntries == [foodEntry])
        #expect(summary.exerciseLogEntries == [exerciseEntry])
        #expect(summary.biometricEntries == [biometricEntry])
        #expect(summary.nutritionTotals.calories == Calories(200))
        #expect(summary.nutritionTotals.carbohydrates == Grams(50))
        #expect(summary.exerciseEstimateTotals.duration == Minutes(20))
        #expect(summary.exerciseEstimateTotals.caloriesBurned == Calories(120))
    }

    @Test func inMemoryRepositoriesSaveListAndDelete() async throws {
        let repository = InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar)
        let dayOneEntry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000501")!,
            loggedAt: Self.day,
            mealType: .lunch,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000502")!,
                name: "Soup",
                nutritionFacts: NutritionFacts(calories: Calories(90))
            ),
            servings: 1
        )
        let dayTwoEntry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000503")!,
            loggedAt: Self.nextDay,
            mealType: .dinner,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000504")!,
                name: "Rice",
                nutritionFacts: NutritionFacts(calories: Calories(210))
            ),
            servings: 1
        )

        _ = try await repository.save(dayOneEntry)
        _ = try await repository.save(dayTwoEntry)

        let recent = try await repository.listRecentEntries(limit: 10)
        #expect(recent == [dayTwoEntry, dayOneEntry])
        #expect(try await repository.listEntries(for: Self.day) == [dayOneEntry])
        #expect(try await repository.listEntries(from: Self.day, through: Self.nextDay) == [dayTwoEntry, dayOneEntry])

        try await repository.delete(id: dayOneEntry.id)
        #expect(try await repository.listRecentEntries(limit: 10) == [dayTwoEntry])
    }

    @Test func exerciseAndBiometricsRepositoriesBehaveLikeInMemoryStores() async throws {
        let exerciseRepository = InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar)
        let biometricsRepository = InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar)

        let exerciseEntry = ExerciseLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000601")!,
            loggedAt: Self.day,
            activity: ExerciseActivity(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000602")!,
                name: "Yoga",
                caloriesBurnedPerMinute: Calories(3)
            ),
            duration: Minutes(45),
            intensity: .light
        )
        let biometricsEntry = BiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000603")!,
            loggedAt: Self.day,
            value: 72,
            kind: .restingHeartRate
        )

        _ = try await exerciseRepository.save(exerciseEntry)
        _ = try await biometricsRepository.save(biometricsEntry)

        #expect(try await exerciseRepository.listRecentEntries(limit: 5) == [exerciseEntry])
        #expect(try await biometricsRepository.listEntries(for: Self.day) == [biometricsEntry])

        try await exerciseRepository.delete(id: exerciseEntry.id)
        try await biometricsRepository.delete(id: biometricsEntry.id)

        let emptyExercises = try await exerciseRepository.listRecentEntries(limit: 5)
        let emptyBiometrics = try await biometricsRepository.listRecentEntries(limit: 5)
        #expect(emptyExercises.isEmpty)
        #expect(emptyBiometrics.isEmpty)
    }
}
