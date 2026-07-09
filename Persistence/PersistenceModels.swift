import Foundation
import SwiftData

@Model
final class FoodLogEntryRecord {
    @Attribute(.unique) var id: UUID
    var loggedAt: Date
    var mealTypeRawValue: String
    var foodItemID: UUID
    var foodItemName: String
    var servings: Double
    var calories: Double?
    var protein: Double?
    var carbohydrates: Double?
    var fat: Double?
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?

    init(
        id: UUID,
        loggedAt: Date,
        mealTypeRawValue: String,
        foodItemID: UUID,
        foodItemName: String,
        servings: Double,
        calories: Double?,
        protein: Double?,
        carbohydrates: Double?,
        fat: Double?,
        fiber: Double?,
        sugar: Double?,
        sodium: Double?
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.mealTypeRawValue = mealTypeRawValue
        self.foodItemID = foodItemID
        self.foodItemName = foodItemName
        self.servings = servings
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }

    convenience init(domain entry: FoodLogEntry) {
        self.init(
            id: entry.id,
            loggedAt: entry.loggedAt,
            mealTypeRawValue: entry.mealType.rawValue,
            foodItemID: entry.foodItem.id,
            foodItemName: entry.foodItem.name,
            servings: entry.servings,
            calories: entry.foodItem.nutritionFacts.calories?.value,
            protein: entry.foodItem.nutritionFacts.protein?.value,
            carbohydrates: entry.foodItem.nutritionFacts.carbohydrates?.value,
            fat: entry.foodItem.nutritionFacts.fat?.value,
            fiber: entry.foodItem.nutritionFacts.fiber?.value,
            sugar: entry.foodItem.nutritionFacts.sugar?.value,
            sodium: entry.foodItem.nutritionFacts.sodium?.value
        )
    }

    var domainValue: FoodLogEntry? {
        guard let mealType = MealType(rawValue: mealTypeRawValue) else {
            return nil
        }

        return FoodLogEntry(
            id: id,
            loggedAt: loggedAt,
            mealType: mealType,
            foodItem: FoodItem(
                id: foodItemID,
                name: foodItemName,
                nutritionFacts: NutritionFacts(
                    calories: calories.map(Calories.init),
                    protein: protein.map(Grams.init),
                    carbohydrates: carbohydrates.map(Grams.init),
                    fat: fat.map(Grams.init),
                    fiber: fiber.map(Grams.init),
                    sugar: sugar.map(Grams.init),
                    sodium: sodium.map(Milligrams.init)
                )
            ),
            servings: servings
        )
    }
}

@Model
final class ExerciseLogEntryRecord {
    @Attribute(.unique) var id: UUID
    var loggedAt: Date
    var activityID: UUID
    var activityName: String
    var caloriesBurnedPerMinute: Double?
    var durationMinutes: Double
    var intensityRawValue: String?

    init(
        id: UUID,
        loggedAt: Date,
        activityID: UUID,
        activityName: String,
        caloriesBurnedPerMinute: Double?,
        durationMinutes: Double,
        intensityRawValue: String?
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.activityID = activityID
        self.activityName = activityName
        self.caloriesBurnedPerMinute = caloriesBurnedPerMinute
        self.durationMinutes = durationMinutes
        self.intensityRawValue = intensityRawValue
    }

    convenience init(domain entry: ExerciseLogEntry) {
        self.init(
            id: entry.id,
            loggedAt: entry.loggedAt,
            activityID: entry.activity.id,
            activityName: entry.activity.name,
            caloriesBurnedPerMinute: entry.activity.caloriesBurnedPerMinute?.value,
            durationMinutes: entry.duration.value,
            intensityRawValue: entry.intensity?.rawValue
        )
    }

    var domainValue: ExerciseLogEntry? {
        ExerciseLogEntry(
            id: id,
            loggedAt: loggedAt,
            activity: ExerciseActivity(
                id: activityID,
                name: activityName,
                caloriesBurnedPerMinute: caloriesBurnedPerMinute.map(Calories.init)
            ),
            duration: Minutes(durationMinutes),
            intensity: intensityRawValue.flatMap(ExerciseIntensity.init(rawValue:))
        )
    }
}

@Model
final class BiometricsEntryRecord {
    @Attribute(.unique) var id: UUID
    var loggedAt: Date
    var kindRawValue: String
    var value: Double

    init(id: UUID, loggedAt: Date, kindRawValue: String, value: Double) {
        self.id = id
        self.loggedAt = loggedAt
        self.kindRawValue = kindRawValue
        self.value = value
    }

    convenience init(domain entry: BiometricsEntry) {
        self.init(
            id: entry.id,
            loggedAt: entry.loggedAt,
            kindRawValue: entry.kind.rawValue,
            value: entry.value
        )
    }

    var domainValue: BiometricsEntry? {
        guard let kind = BiometricsKind(rawValue: kindRawValue) else {
            return nil
        }

        return BiometricsEntry(
            id: id,
            loggedAt: loggedAt,
            value: value,
            kind: kind
        )
    }
}
