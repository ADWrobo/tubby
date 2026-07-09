import Foundation

actor InMemoryFoodLogEntryRepository: FoodLogEntryRepository {
    private var entries: [FoodLogEntry] = []
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async throws -> [FoodLogEntry] {
        guard limit > 0 else { return [] }
        return Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async throws -> [FoodLogEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async throws -> [FoodLogEntry] {
        sortedEntries.filter { $0.loggedAt >= startDate && $0.loggedAt <= endDate }
    }

    func save(_ entry: FoodLogEntry) async throws -> FoodLogEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: FoodLogEntry.ID) async throws {
        entries.removeAll { $0.id == id }
    }

    private var sortedEntries: [FoodLogEntry] {
        entries.sorted { $0.loggedAt > $1.loggedAt }
    }

    private func filteredEntries(for interval: DateInterval) -> [FoodLogEntry] {
        sortedEntries.filter { interval.contains($0.loggedAt) }
    }

    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

actor InMemoryExerciseLogEntryRepository: ExerciseLogEntryRepository {
    private var entries: [ExerciseLogEntry] = []
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async throws -> [ExerciseLogEntry] {
        guard limit > 0 else { return [] }
        return Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async throws -> [ExerciseLogEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async throws -> [ExerciseLogEntry] {
        sortedEntries.filter { $0.loggedAt >= startDate && $0.loggedAt <= endDate }
    }

    func save(_ entry: ExerciseLogEntry) async throws -> ExerciseLogEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: ExerciseLogEntry.ID) async throws {
        entries.removeAll { $0.id == id }
    }

    private var sortedEntries: [ExerciseLogEntry] {
        entries.sorted { $0.loggedAt > $1.loggedAt }
    }

    private func filteredEntries(for interval: DateInterval) -> [ExerciseLogEntry] {
        sortedEntries.filter { interval.contains($0.loggedAt) }
    }

    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

actor InMemoryBiometricsEntryRepository: BiometricsEntryRepository {
    private var entries: [BiometricsEntry] = []
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async throws -> [BiometricsEntry] {
        guard limit > 0 else { return [] }
        return Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async throws -> [BiometricsEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async throws -> [BiometricsEntry] {
        sortedEntries.filter { $0.loggedAt >= startDate && $0.loggedAt <= endDate }
    }

    func save(_ entry: BiometricsEntry) async throws -> BiometricsEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: BiometricsEntry.ID) async throws {
        entries.removeAll { $0.id == id }
    }

    private var sortedEntries: [BiometricsEntry] {
        entries.sorted { $0.loggedAt > $1.loggedAt }
    }

    private func filteredEntries(for interval: DateInterval) -> [BiometricsEntry] {
        sortedEntries.filter { interval.contains($0.loggedAt) }
    }
    
    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

struct NoopFoodLookupProvider: FoodLookupProviding {
    func searchFoods(named query: String) async throws -> [FoodReference] { [] }
}

struct NoopExerciseLookupProvider: ExerciseLookupProviding {
    func searchExercises(named query: String) async throws -> [ExerciseReference] { [] }
}

private func upsert<T: Identifiable>(_ entry: T, into entries: inout [T]) where T.ID: Equatable {
    if let index = entries.firstIndex(where: { $0.id == entry.id }) {
        entries[index] = entry
    } else {
        entries.append(entry)
    }
}
