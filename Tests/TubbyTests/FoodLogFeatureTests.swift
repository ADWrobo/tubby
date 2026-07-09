import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct FoodLogFeatureTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func blankFoodNameCannotSave() {
        let draft = FoodLogEntryDraft(
            foodName: "   ",
            servingsText: "1"
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch FoodLogEntryDraft.ValidationError.missingFoodName {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func blankOptionalNutritionFieldsMapToNil() throws {
        let draft = FoodLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000004001")!,
            foodItemID: UUID(uuidString: "00000000-0000-0000-0000-000000004002")!,
            foodName: "Greek yogurt",
            mealType: .snack,
            loggedAt: Self.day,
            servingsText: "1",
            caloriesText: "",
            proteinText: "",
            carbohydratesText: "",
            fatText: "",
            fiberText: "",
            sugarText: "",
            sodiumText: ""
        )

        let entry = try draft.makeEntry()

        #expect(entry.foodItem.nutritionFacts.calories == nil)
        #expect(entry.foodItem.nutritionFacts.protein == nil)
        #expect(entry.foodItem.nutritionFacts.carbohydrates == nil)
        #expect(entry.foodItem.nutritionFacts.fat == nil)
        #expect(entry.foodItem.nutritionFacts.fiber == nil)
        #expect(entry.foodItem.nutritionFacts.sugar == nil)
        #expect(entry.foodItem.nutritionFacts.sodium == nil)
    }

    @Test func numericNutritionFieldsMapToCorrectWrappers() throws {
        let draft = FoodLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000004101")!,
            foodItemID: UUID(uuidString: "00000000-0000-0000-0000-000000004102")!,
            foodName: "Lunch bowl",
            mealType: .lunch,
            loggedAt: Self.day,
            servingsText: "1.5",
            caloriesText: "250",
            proteinText: "20",
            carbohydratesText: "30",
            fatText: "8",
            fiberText: "5",
            sugarText: "10",
            sodiumText: "450"
        )

        let entry = try draft.makeEntry()

        #expect(entry.servings == 1.5)
        #expect(entry.foodItem.nutritionFacts.calories == Calories(250))
        #expect(entry.foodItem.nutritionFacts.protein == Grams(20))
        #expect(entry.foodItem.nutritionFacts.carbohydrates == Grams(30))
        #expect(entry.foodItem.nutritionFacts.fat == Grams(8))
        #expect(entry.foodItem.nutritionFacts.fiber == Grams(5))
        #expect(entry.foodItem.nutritionFacts.sugar == Grams(10))
        #expect(entry.foodItem.nutritionFacts.sodium == Milligrams(450))
    }

    @Test func editModePreservesExistingEntryIdentity() throws {
        let entry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000004201")!,
            loggedAt: Self.day,
            mealType: .dinner,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000004202")!,
                name: "Soup",
                nutritionFacts: NutritionFacts(calories: Calories(120))
            ),
            servings: 2
        )

        let draft = FoodLogEntryDraft(entry: entry)
        let rebuilt = try draft.makeEntry()

        #expect(rebuilt.id == entry.id)
        #expect(rebuilt.foodItem.id == entry.foodItem.id)
        #expect(rebuilt.foodItem.name == entry.foodItem.name)
    }

    @MainActor
    @Test func saveCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar)
        let viewModel = FoodLogViewModel(repository: repository, selectedDate: Self.day, calendar: Self.utcCalendar)

        let draft = FoodLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000004301")!,
            foodItemID: UUID(uuidString: "00000000-0000-0000-0000-000000004302")!,
            foodName: "Breakfast wrap",
            mealType: .breakfast,
            loggedAt: Self.day,
            servingsText: "1",
            caloriesText: "320",
            proteinText: "18",
            carbohydratesText: "28",
            fatText: "14",
            fiberText: "4",
            sugarText: "3",
            sodiumText: "520"
        )

        try await viewModel.save(draft)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.first?.foodItem.name == "Breakfast wrap")
    }

    @MainActor
    @Test func deleteCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryFoodLogEntryRepository(calendar: Self.utcCalendar)
        let existingEntry = FoodLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000004401")!,
            loggedAt: Self.day,
            mealType: .snack,
            foodItem: FoodItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000004402")!,
                name: "Yogurt",
                nutritionFacts: NutritionFacts(calories: Calories(100))
            ),
            servings: 1
        )
        _ = try await repository.save(existingEntry)

        let viewModel = FoodLogViewModel(repository: repository, selectedDate: Self.day, calendar: Self.utcCalendar)
        await viewModel.loadEntries()
        #expect(viewModel.entries == [existingEntry])

        try await viewModel.delete(existingEntry)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.isEmpty)
    }
}
