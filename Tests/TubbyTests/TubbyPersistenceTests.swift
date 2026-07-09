import Foundation
import SwiftData
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct TubbyPersistenceTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)
    private static let nextDay = Date(timeIntervalSince1970: 1_700_086_400)

    @MainActor
    @Test func domainModelsRoundTripThroughSwiftDataRecords() {
        let foodEntry = makeFoodEntry()
        let exerciseEntry = makeExerciseEntry()
        let biometricsEntry = makeBiometricsEntry()

        #expect(FoodLogEntryRecord(domain: foodEntry).domainValue == foodEntry)
        #expect(ExerciseLogEntryRecord(domain: exerciseEntry).domainValue == exerciseEntry)
        #expect(BiometricsEntryRecord(domain: biometricsEntry).domainValue == biometricsEntry)
    }

    @MainActor
    @Test func invalidRawValuesAreHandledDefensively() {
        let foodRecord = FoodLogEntryRecord(domain: makeFoodEntry())
        foodRecord.mealTypeRawValue = "not-a-meal-type"

        let exerciseRecord = ExerciseLogEntryRecord(domain: makeExerciseEntry())
        exerciseRecord.intensityRawValue = "not-an-intensity"

        let biometricsRecord = BiometricsEntryRecord(domain: makeBiometricsEntry())
        biometricsRecord.kindRawValue = "not-a-kind"

        #expect(foodRecord.domainValue == nil)
        #expect(exerciseRecord.domainValue?.intensity == nil)
        #expect(biometricsRecord.domainValue == nil)
    }

    @MainActor
    @Test func swiftDataFoodRepositorySavesListsAndDeletes() async {
        let container = makeContainer()
        let repository = SwiftDataFoodLogEntryRepository(modelContext: container.mainContext, calendar: Self.utcCalendar)

        let dayEntry = makeFoodEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000001001")!,
            loggedAt: Self.day,
            name: "Oatmeal",
            calories: 150,
            servings: 1
        )
        let nextDayEntry = makeFoodEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000001002")!,
            loggedAt: Self.nextDay,
            name: "Sandwich",
            calories: 320,
            servings: 1
        )
        let updatedDayEntry = makeFoodEntry(
            id: dayEntry.id,
            loggedAt: Self.day,
            name: "Oatmeal Deluxe",
            calories: 200,
            servings: 2
        )

        _ = await repository.save(dayEntry)
        _ = await repository.save(nextDayEntry)
        _ = await repository.save(updatedDayEntry)

        let recent = await repository.listRecentEntries(limit: 10)
        #expect(recent == [nextDayEntry, updatedDayEntry])
        #expect(await repository.listEntries(for: Self.day) == [updatedDayEntry])
        #expect(await repository.listEntries(from: Self.day, through: Self.nextDay) == [nextDayEntry, updatedDayEntry])

        await repository.delete(id: updatedDayEntry.id)
        #expect(await repository.listRecentEntries(limit: 10) == [nextDayEntry])
    }

    @MainActor
    @Test func swiftDataExerciseRepositorySavesListsAndDeletes() async {
        let container = makeContainer()
        let repository = SwiftDataExerciseLogEntryRepository(modelContext: container.mainContext, calendar: Self.utcCalendar)

        let dayEntry = makeExerciseEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000002001")!,
            loggedAt: Self.day,
            name: "Walking",
            rate: 4,
            duration: 30,
            intensity: .moderate
        )
        let nextDayEntry = makeExerciseEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000002002")!,
            loggedAt: Self.nextDay,
            name: "Cycling",
            rate: 6,
            duration: 45,
            intensity: .vigorous
        )
        let updatedDayEntry = makeExerciseEntry(
            id: dayEntry.id,
            loggedAt: Self.day,
            name: "Walking Plus",
            rate: 5,
            duration: 40,
            intensity: .light
        )

        _ = await repository.save(dayEntry)
        _ = await repository.save(nextDayEntry)
        _ = await repository.save(updatedDayEntry)

        let recent = await repository.listRecentEntries(limit: 10)
        #expect(recent == [nextDayEntry, updatedDayEntry])
        #expect(await repository.listEntries(for: Self.day) == [updatedDayEntry])
        #expect(await repository.listEntries(from: Self.day, through: Self.nextDay) == [nextDayEntry, updatedDayEntry])

        await repository.delete(id: updatedDayEntry.id)
        #expect(await repository.listRecentEntries(limit: 10) == [nextDayEntry])
    }

    @MainActor
    @Test func swiftDataBiometricsRepositorySavesListsAndDeletes() async {
        let container = makeContainer()
        let repository = SwiftDataBiometricsEntryRepository(modelContext: container.mainContext, calendar: Self.utcCalendar)

        let dayEntry = makeBiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000003001")!,
            loggedAt: Self.day,
            kind: .weight,
            value: 180
        )
        let nextDayEntry = makeBiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000003002")!,
            loggedAt: Self.nextDay,
            kind: .restingHeartRate,
            value: 62
        )
        let updatedDayEntry = makeBiometricsEntry(
            id: dayEntry.id,
            loggedAt: Self.day,
            kind: .waistMeasurement,
            value: 32
        )

        _ = await repository.save(dayEntry)
        _ = await repository.save(nextDayEntry)
        _ = await repository.save(updatedDayEntry)

        let recent = await repository.listRecentEntries(limit: 10)
        #expect(recent == [nextDayEntry, updatedDayEntry])
        #expect(await repository.listEntries(for: Self.day) == [updatedDayEntry])
        #expect(await repository.listEntries(from: Self.day, through: Self.nextDay) == [nextDayEntry, updatedDayEntry])

        await repository.delete(id: updatedDayEntry.id)
        #expect(await repository.listRecentEntries(limit: 10) == [nextDayEntry])
    }

    private func makeContainer() -> ModelContainer {
        try! ModelContainer(
            for: FoodLogEntryRecord.self,
            ExerciseLogEntryRecord.self,
            BiometricsEntryRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func makeFoodEntry(
        id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000001000")!,
        loggedAt: Date = Self.day,
        name: String = "Oatmeal",
        calories: Double = 150,
        servings: Double = 1
    ) -> FoodLogEntry {
        FoodLogEntry(
            id: id,
            loggedAt: loggedAt,
            mealType: .breakfast,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000001100")!,
                name: name,
                nutritionFacts: NutritionFacts(
                    calories: Calories(calories),
                    protein: Grams(5),
                    carbohydrates: Grams(27),
                    fat: Grams(3),
                    fiber: Grams(4),
                    sugar: Grams(8),
                    sodium: Milligrams(120)
                )
            ),
            servings: servings
        )
    }

    private func makeExerciseEntry(
        id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000002000")!,
        loggedAt: Date = Self.day,
        name: String = "Walking",
        rate: Double = 4,
        duration: Double = 30,
        intensity: ExerciseIntensity? = .moderate
    ) -> ExerciseLogEntry {
        ExerciseLogEntry(
            id: id,
            loggedAt: loggedAt,
            activity: ExerciseActivity(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000002100")!,
                name: name,
                caloriesBurnedPerMinute: Calories(rate)
            ),
            duration: Minutes(duration),
            intensity: intensity
        )
    }

    private func makeBiometricsEntry(
        id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000003000")!,
        loggedAt: Date = Self.day,
        kind: BiometricsKind = .weight,
        value: Double = 180
    ) -> BiometricsEntry {
        BiometricsEntry(
            id: id,
            loggedAt: loggedAt,
            value: value,
            kind: kind
        )
    }
}
