import Foundation

struct InMemoryMealRepository: MealRepository {
    func recentMeals() async throws -> [Meal] { [] }
}

struct InMemoryExerciseRepository: ExerciseRepository {
    func recentExercises() async throws -> [Exercise] { [] }
}

struct InMemoryBiometricsRepository: BiometricsRepository {
    func recentEntries() async throws -> [BiometricsEntry] { [] }
}

struct NoopFoodLookupProvider: FoodLookupProviding {
    func searchFoods(named query: String) async throws -> [FoodReference] { [] }
}

struct NoopExerciseLookupProvider: ExerciseLookupProviding {
    func searchExercises(named query: String) async throws -> [ExerciseReference] { [] }
}
