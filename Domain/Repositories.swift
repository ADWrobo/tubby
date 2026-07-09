import Foundation

protocol FoodLogEntryRepository {
    func listRecentEntries(limit: Int) async throws -> [FoodLogEntry]
    func listEntries(for date: Date) async throws -> [FoodLogEntry]
    func listEntries(from startDate: Date, through endDate: Date) async throws -> [FoodLogEntry]
    func save(_ entry: FoodLogEntry) async throws -> FoodLogEntry
    func delete(id: FoodLogEntry.ID) async throws
}

protocol ExerciseLogEntryRepository {
    func listRecentEntries(limit: Int) async throws -> [ExerciseLogEntry]
    func listEntries(for date: Date) async throws -> [ExerciseLogEntry]
    func listEntries(from startDate: Date, through endDate: Date) async throws -> [ExerciseLogEntry]
    func save(_ entry: ExerciseLogEntry) async throws -> ExerciseLogEntry
    func delete(id: ExerciseLogEntry.ID) async throws
}

protocol BiometricsEntryRepository {
    func listRecentEntries(limit: Int) async throws -> [BiometricsEntry]
    func listEntries(for date: Date) async throws -> [BiometricsEntry]
    func listEntries(from startDate: Date, through endDate: Date) async throws -> [BiometricsEntry]
    func save(_ entry: BiometricsEntry) async throws -> BiometricsEntry
    func delete(id: BiometricsEntry.ID) async throws
}
