import Foundation

struct AppEnvironment: Sendable {
    var mealRepository: any MealRepository
    var exerciseRepository: any ExerciseRepository
    var biometricsRepository: any BiometricsRepository
    var foodLookupProvider: any FoodLookupProviding
    var exerciseLookupProvider: any ExerciseLookupProviding

    static let live = AppEnvironment(
        mealRepository: InMemoryMealRepository(),
        exerciseRepository: InMemoryExerciseRepository(),
        biometricsRepository: InMemoryBiometricsRepository(),
        foodLookupProvider: NoopFoodLookupProvider(),
        exerciseLookupProvider: NoopExerciseLookupProvider()
    )
}
