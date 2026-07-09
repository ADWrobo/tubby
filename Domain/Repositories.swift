import Foundation

protocol FoodLogEntryRepository {
    func listRecentEntries(limit: Int) async -> [FoodLogEntry]
    func listEntries(for date: Date) async -> [FoodLogEntry]
    func listEntries(from startDate: Date, through endDate: Date) async -> [FoodLogEntry]
    func save(_ entry: FoodLogEntry) async -> FoodLogEntry
    func delete(id: FoodLogEntry.ID) async
}

protocol ExerciseLogEntryRepository {
    func listRecentEntries(limit: Int) async -> [ExerciseLogEntry]
    func listEntries(for date: Date) async -> [ExerciseLogEntry]
    func listEntries(from startDate: Date, through endDate: Date) async -> [ExerciseLogEntry]
    func save(_ entry: ExerciseLogEntry) async -> ExerciseLogEntry
    func delete(id: ExerciseLogEntry.ID) async
}

protocol BiometricsEntryRepository {
    func listRecentEntries(limit: Int) async -> [BiometricsEntry]
    func listEntries(for date: Date) async -> [BiometricsEntry]
    func listEntries(from startDate: Date, through endDate: Date) async -> [BiometricsEntry]
    func save(_ entry: BiometricsEntry) async -> BiometricsEntry
    func delete(id: BiometricsEntry.ID) async
}
