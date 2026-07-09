import Foundation

struct MealRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let title: String
}

struct ExerciseRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let title: String
}

struct BiometricsRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let kind: String
    let value: Double
}
