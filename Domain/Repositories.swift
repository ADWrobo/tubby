import Foundation

protocol MealRepository: Sendable {
    func recentMeals() async throws -> [Meal]
}

protocol ExerciseRepository: Sendable {
    func recentExercises() async throws -> [Exercise]
}

protocol BiometricsRepository: Sendable {
    func recentEntries() async throws -> [BiometricsEntry]
}
