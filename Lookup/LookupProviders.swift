import Foundation

protocol FoodLookupProviding: Sendable {
    func searchFoods(named query: String) async throws -> [FoodReference]
}

protocol ExerciseLookupProviding: Sendable {
    func searchExercises(named query: String) async throws -> [ExerciseReference]
}

struct FoodReference: Equatable, Sendable {
    let id: String
    let name: String
}

struct ExerciseReference: Equatable, Sendable {
    let id: String
    let name: String
}
