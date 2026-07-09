import Foundation

struct FoodLogEntryDraft: Identifiable, Equatable, Sendable {
    enum Mode: Equatable, Sendable {
        case add
        case edit
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case missingFoodName
        case invalidServings
        case invalidNumber(field: String)

        var errorDescription: String? {
            switch self {
            case .missingFoodName:
                return "Enter a food name."
            case .invalidServings:
                return "Servings need to be greater than 0."
            case .invalidNumber(let field):
                return "\(field) needs a valid number or can be left blank."
            }
        }
    }

    let id: UUID
    let foodItemID: UUID
    let mode: Mode

    var foodName: String
    var mealType: MealType
    var loggedAt: Date
    var servingsText: String
    var caloriesText: String
    var proteinText: String
    var carbohydratesText: String
    var fatText: String
    var fiberText: String
    var sugarText: String
    var sodiumText: String

    init(
        id: UUID = UUID(),
        foodItemID: UUID = UUID(),
        mode: Mode = .add,
        foodName: String = "",
        mealType: MealType = .breakfast,
        loggedAt: Date = Date(),
        servingsText: String = "1",
        caloriesText: String = "",
        proteinText: String = "",
        carbohydratesText: String = "",
        fatText: String = "",
        fiberText: String = "",
        sugarText: String = "",
        sodiumText: String = ""
    ) {
        self.id = id
        self.foodItemID = foodItemID
        self.mode = mode
        self.foodName = foodName
        self.mealType = mealType
        self.loggedAt = loggedAt
        self.servingsText = servingsText
        self.caloriesText = caloriesText
        self.proteinText = proteinText
        self.carbohydratesText = carbohydratesText
        self.fatText = fatText
        self.fiberText = fiberText
        self.sugarText = sugarText
        self.sodiumText = sodiumText
    }

    init(entry: FoodLogEntry) {
        self.init(
            id: entry.id,
            foodItemID: entry.foodItem.id,
            mode: .edit,
            foodName: entry.foodItem.name,
            mealType: entry.mealType,
            loggedAt: entry.loggedAt,
            servingsText: Self.string(from: entry.servings),
            caloriesText: Self.string(from: entry.foodItem.nutritionFacts.calories?.value),
            proteinText: Self.string(from: entry.foodItem.nutritionFacts.protein?.value),
            carbohydratesText: Self.string(from: entry.foodItem.nutritionFacts.carbohydrates?.value),
            fatText: Self.string(from: entry.foodItem.nutritionFacts.fat?.value),
            fiberText: Self.string(from: entry.foodItem.nutritionFacts.fiber?.value),
            sugarText: Self.string(from: entry.foodItem.nutritionFacts.sugar?.value),
            sodiumText: Self.string(from: entry.foodItem.nutritionFacts.sodium?.value)
        )
    }

    var isValidForSaving: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && parsedServings > 0
    }

    func makeEntry() throws -> FoodLogEntry {
        let trimmedFoodName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedFoodName.isEmpty else {
            throw ValidationError.missingFoodName
        }

        let servings = try parseRequiredNumber(servingsText, field: "Servings")
        guard servings > 0 else {
            throw ValidationError.invalidServings
        }

        let nutritionFacts = NutritionFacts(
            calories: try parseOptionalNumber(caloriesText, field: "Calories", wrap: Calories.init),
            protein: try parseOptionalNumber(proteinText, field: "Protein", wrap: Grams.init),
            carbohydrates: try parseOptionalNumber(carbohydratesText, field: "Carbohydrates", wrap: Grams.init),
            fat: try parseOptionalNumber(fatText, field: "Fat", wrap: Grams.init),
            fiber: try parseOptionalNumber(fiberText, field: "Fiber", wrap: Grams.init),
            sugar: try parseOptionalNumber(sugarText, field: "Sugar", wrap: Grams.init),
            sodium: try parseOptionalNumber(sodiumText, field: "Sodium", wrap: Milligrams.init)
        )

        return FoodLogEntry(
            id: id,
            loggedAt: loggedAt,
            mealType: mealType,
            foodItem: FoodItem(
                id: foodItemID,
                name: trimmedFoodName,
                nutritionFacts: nutritionFacts
            ),
            servings: servings
        )
    }

    private var parsedServings: Double {
        Double(servingsText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private func parseRequiredNumber(_ text: String, field: String) throws -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed) else {
            throw ValidationError.invalidNumber(field: field)
        }
        return value
    }

    private func parseOptionalNumber<T>(
        _ text: String,
        field: String,
        wrap: (Double) -> T
    ) throws -> T? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        guard let value = Double(trimmed) else {
            throw ValidationError.invalidNumber(field: field)
        }
        return wrap(value)
    }

    private static func string(from value: Double?) -> String {
        guard let value else { return "" }
        return string(from: value)
    }

    private static func string(from value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return String(value)
    }
}

extension MealType {
    var displayName: String {
        rawValue.capitalized
    }
}
