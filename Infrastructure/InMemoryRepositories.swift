import Foundation

actor InMemoryFoodLogEntryRepository: FoodLogEntryRepository {
    private var entries: [FoodLogEntry] = []
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async -> [FoodLogEntry] {
        Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async -> [FoodLogEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [FoodLogEntry] {
        filteredEntries(for: DateInterval(start: startDate, end: endDate))
    }

    func save(_ entry: FoodLogEntry) async -> FoodLogEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: FoodLogEntry.ID) async {
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

    func listRecentEntries(limit: Int) async -> [ExerciseLogEntry] {
        Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async -> [ExerciseLogEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [ExerciseLogEntry] {
        filteredEntries(for: DateInterval(start: startDate, end: endDate))
    }

    func save(_ entry: ExerciseLogEntry) async -> ExerciseLogEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: ExerciseLogEntry.ID) async {
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

    func listRecentEntries(limit: Int) async -> [BiometricsEntry] {
        Array(sortedEntries.prefix(limit))
    }

    func listEntries(for date: Date) async -> [BiometricsEntry] {
        filteredEntries(for: dateInterval(for: date))
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [BiometricsEntry] {
        filteredEntries(for: DateInterval(start: startDate, end: endDate))
    }

    func save(_ entry: BiometricsEntry) async -> BiometricsEntry {
        upsert(entry, into: &entries)
        return entry
    }

    func delete(id: BiometricsEntry.ID) async {
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
