import Foundation

struct AppEnvironment: Sendable {
    var foodLogEntryRepository: any FoodLogEntryRepository
    var exerciseLogEntryRepository: any ExerciseLogEntryRepository
    var biometricsEntryRepository: any BiometricsEntryRepository
    var foodLookupProvider: any FoodLookupProviding
    var exerciseLookupProvider: any ExerciseLookupProviding

    static let live = AppEnvironment(
        foodLogEntryRepository: InMemoryFoodLogEntryRepository(),
        exerciseLogEntryRepository: InMemoryExerciseLogEntryRepository(),
        biometricsEntryRepository: InMemoryBiometricsEntryRepository(),
        foodLookupProvider: NoopFoodLookupProvider(),
        exerciseLookupProvider: NoopExerciseLookupProvider()
    )
}
