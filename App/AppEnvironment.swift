import Foundation
import SwiftData

struct AppEnvironment {
    var foodLogEntryRepository: any FoodLogEntryRepository
    var exerciseLogEntryRepository: any ExerciseLogEntryRepository
    var biometricsEntryRepository: any BiometricsEntryRepository
    var foodLookupProvider: any FoodLookupProviding
    var exerciseLookupProvider: any ExerciseLookupProviding

    @MainActor
    static func live(modelContext: ModelContext) -> AppEnvironment {
        AppEnvironment(
            foodLogEntryRepository: SwiftDataFoodLogEntryRepository(modelContext: modelContext),
            exerciseLogEntryRepository: SwiftDataExerciseLogEntryRepository(modelContext: modelContext),
            biometricsEntryRepository: SwiftDataBiometricsEntryRepository(modelContext: modelContext),
            foodLookupProvider: NoopFoodLookupProvider(),
            exerciseLookupProvider: NoopExerciseLookupProvider()
        )
    }
}
