import Foundation

struct Calories: Equatable, Sendable {
    var value: Double

    init(_ value: Double) {
        self.value = value
    }
}

struct Grams: Equatable, Sendable {
    var value: Double

    init(_ value: Double) {
        self.value = value
    }
}

struct Milligrams: Equatable, Sendable {
    var value: Double

    init(_ value: Double) {
        self.value = value
    }
}

struct Minutes: Equatable, Sendable {
    var value: Double

    init(_ value: Double) {
        self.value = value
    }
}

enum BodyMassUnit: String, Equatable, Sendable {
    case kilograms
    case pounds
}

struct BodyMass: Equatable, Sendable {
    var value: Double
    var unit: BodyMassUnit
}

struct NutritionFacts: Equatable, Sendable {
    var calories: Calories?
    var protein: Grams?
    var carbohydrates: Grams?
    var fat: Grams?
    var fiber: Grams?
    var sugar: Grams?
    var sodium: Milligrams?

    init(
        calories: Calories? = nil,
        protein: Grams? = nil,
        carbohydrates: Grams? = nil,
        fat: Grams? = nil,
        fiber: Grams? = nil,
        sugar: Grams? = nil,
        sodium: Milligrams? = nil
    ) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }

    func scaled(by factor: Double) -> NutritionFacts {
        NutritionFacts(
            calories: calories.map { Calories($0.value * factor) },
            protein: protein.map { Grams($0.value * factor) },
            carbohydrates: carbohydrates.map { Grams($0.value * factor) },
            fat: fat.map { Grams($0.value * factor) },
            fiber: fiber.map { Grams($0.value * factor) },
            sugar: sugar.map { Grams($0.value * factor) },
            sodium: sodium.map { Milligrams($0.value * factor) }
        )
    }

    func adding(_ other: NutritionFacts) -> NutritionFacts {
        NutritionFacts(
            calories: calories.adding(other.calories, wrap: Calories.init),
            protein: protein.adding(other.protein, wrap: Grams.init),
            carbohydrates: carbohydrates.adding(other.carbohydrates, wrap: Grams.init),
            fat: fat.adding(other.fat, wrap: Grams.init),
            fiber: fiber.adding(other.fiber, wrap: Grams.init),
            sugar: sugar.adding(other.sugar, wrap: Grams.init),
            sodium: sodium.adding(other.sodium, wrap: Milligrams.init)
        )
    }
}

private extension Optional where Wrapped == Calories {
    func adding(_ other: Calories?, wrap: (Double) -> Calories) -> Calories? {
        switch (self, other) {
        case let (.some(lhs), .some(rhs)):
            return wrap(lhs.value + rhs.value)
        case let (.some(lhs), .none):
            return lhs
        case let (.none, .some(rhs)):
            return rhs
        case (.none, .none):
            return nil
        }
    }
}

private extension Optional where Wrapped == Grams {
    func adding(_ other: Grams?, wrap: (Double) -> Grams) -> Grams? {
        switch (self, other) {
        case let (.some(lhs), .some(rhs)):
            return wrap(lhs.value + rhs.value)
        case let (.some(lhs), .none):
            return lhs
        case let (.none, .some(rhs)):
            return rhs
        case (.none, .none):
            return nil
        }
    }
}

private extension Optional where Wrapped == Milligrams {
    func adding(_ other: Milligrams?, wrap: (Double) -> Milligrams) -> Milligrams? {
        switch (self, other) {
        case let (.some(lhs), .some(rhs)):
            return wrap(lhs.value + rhs.value)
        case let (.some(lhs), .none):
            return lhs
        case let (.none, .some(rhs)):
            return rhs
        case (.none, .none):
            return nil
        }
    }
}

struct FoodItem: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var nutritionFacts: NutritionFacts
}

enum MealType: String, CaseIterable, Equatable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack
    case other
}

struct FoodLogEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var loggedAt: Date
    var mealType: MealType
    var foodItem: FoodItem
    var servings: Double

    func nutritionFacts() -> NutritionFacts {
        foodItem.nutritionFacts.scaled(by: servings)
    }
}

enum ExerciseIntensity: String, CaseIterable, Equatable, Sendable {
    case light
    case moderate
    case vigorous
}

struct ExerciseActivity: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var caloriesBurnedPerMinute: Calories?
}

struct ExerciseLogEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var loggedAt: Date
    var activity: ExerciseActivity
    var duration: Minutes
    var intensity: ExerciseIntensity?

    func estimatedCaloriesBurned() -> Calories? {
        guard let rate = activity.caloriesBurnedPerMinute else {
            return nil
        }
        return Calories(rate.value * duration.value)
    }
}

enum BiometricsKind: String, CaseIterable, Equatable, Sendable {
    case weight
    case systolicBloodPressure
    case diastolicBloodPressure
    case restingHeartRate
    case waistMeasurement
}

struct BiometricsEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var loggedAt: Date
    var value: Double
    var kind: BiometricsKind
}

struct ExerciseEstimateTotals: Equatable, Sendable {
    var caloriesBurned: Calories
    var duration: Minutes

    static let zero = ExerciseEstimateTotals(caloriesBurned: Calories(0), duration: Minutes(0))
}

struct DailySummary: Equatable, Sendable {
    var date: Date
    var foodLogEntries: [FoodLogEntry]
    var exerciseLogEntries: [ExerciseLogEntry]
    var biometricEntries: [BiometricsEntry]
    var nutritionTotals: NutritionFacts
    var exerciseEstimateTotals: ExerciseEstimateTotals

    init(
        date: Date,
        foodLogEntries: [FoodLogEntry] = [],
        exerciseLogEntries: [ExerciseLogEntry] = [],
        biometricEntries: [BiometricsEntry] = []
    ) {
        self.date = date
        self.foodLogEntries = foodLogEntries
        self.exerciseLogEntries = exerciseLogEntries
        self.biometricEntries = biometricEntries
        nutritionTotals = foodLogEntries
            .map { $0.nutritionFacts() }
            .reduce(NutritionFacts(), { $0.adding($1) })
        exerciseEstimateTotals = exerciseLogEntries.reduce(.zero) { partialResult, entry in
            var result = partialResult
            result.duration = Minutes(result.duration.value + entry.duration.value)
            if let calories = entry.estimatedCaloriesBurned() {
                result.caloriesBurned = Calories(result.caloriesBurned.value + calories.value)
            }
            return result
        }
    }
}
