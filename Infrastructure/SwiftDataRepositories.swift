import Foundation
import SwiftData

@MainActor
final class SwiftDataFoodLogEntryRepository: FoodLogEntryRepository {
    private let modelContext: ModelContext
    private let calendar: Calendar

    init(modelContext: ModelContext, calendar: Calendar = .current) {
        self.modelContext = modelContext
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async -> [FoodLogEntry] {
        guard limit > 0 else { return [] }
        return fetchRecords(
            in: modelContext,
            FoodLogEntryRecord.self,
            predicate: nil,
            sortBy: [SortDescriptor(\FoodLogEntryRecord.loggedAt, order: .reverse)],
            fetchLimit: limit
        ).compactMap(\.domainValue)
    }

    func listEntries(for date: Date) async -> [FoodLogEntry] {
        let interval = dateInterval(for: date)
        let start = interval.start
        let end = interval.end
        return fetchRecords(
            in: modelContext,
            FoodLogEntryRecord.self,
            predicate: #Predicate<FoodLogEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt < end
            },
            sortBy: [SortDescriptor(\FoodLogEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [FoodLogEntry] {
        let start = startDate
        let end = endDate
        return fetchRecords(
            in: modelContext,
            FoodLogEntryRecord.self,
            predicate: #Predicate<FoodLogEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt <= end
            },
            sortBy: [SortDescriptor(\FoodLogEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func save(_ entry: FoodLogEntry) async -> FoodLogEntry {
        if let record = fetchRecord(in: modelContext, id: entry.id) {
            update(record, from: entry)
        } else {
            modelContext.insert(FoodLogEntryRecord(domain: entry))
        }
        saveContext()
        return entry
    }

    func delete(id: FoodLogEntry.ID) async {
        if let record = fetchRecord(in: modelContext, id: id) {
            modelContext.delete(record)
            saveContext()
        }
    }

    private func update(_ record: FoodLogEntryRecord, from entry: FoodLogEntry) {
        record.loggedAt = entry.loggedAt
        record.mealTypeRawValue = entry.mealType.rawValue
        record.foodItemID = entry.foodItem.id
        record.foodItemName = entry.foodItem.name
        record.servings = entry.servings
        record.calories = entry.foodItem.nutritionFacts.calories?.value
        record.protein = entry.foodItem.nutritionFacts.protein?.value
        record.carbohydrates = entry.foodItem.nutritionFacts.carbohydrates?.value
        record.fat = entry.foodItem.nutritionFacts.fat?.value
        record.fiber = entry.foodItem.nutritionFacts.fiber?.value
        record.sugar = entry.foodItem.nutritionFacts.sugar?.value
        record.sodium = entry.foodItem.nutritionFacts.sodium?.value
    }

    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

@MainActor
final class SwiftDataExerciseLogEntryRepository: ExerciseLogEntryRepository {
    private let modelContext: ModelContext
    private let calendar: Calendar

    init(modelContext: ModelContext, calendar: Calendar = .current) {
        self.modelContext = modelContext
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async -> [ExerciseLogEntry] {
        guard limit > 0 else { return [] }
        return fetchRecords(
            in: modelContext,
            ExerciseLogEntryRecord.self,
            predicate: nil,
            sortBy: [SortDescriptor(\ExerciseLogEntryRecord.loggedAt, order: .reverse)],
            fetchLimit: limit
        ).compactMap(\.domainValue)
    }

    func listEntries(for date: Date) async -> [ExerciseLogEntry] {
        let interval = dateInterval(for: date)
        let start = interval.start
        let end = interval.end
        return fetchRecords(
            in: modelContext,
            ExerciseLogEntryRecord.self,
            predicate: #Predicate<ExerciseLogEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt < end
            },
            sortBy: [SortDescriptor(\ExerciseLogEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [ExerciseLogEntry] {
        let start = startDate
        let end = endDate
        return fetchRecords(
            in: modelContext,
            ExerciseLogEntryRecord.self,
            predicate: #Predicate<ExerciseLogEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt <= end
            },
            sortBy: [SortDescriptor(\ExerciseLogEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func save(_ entry: ExerciseLogEntry) async -> ExerciseLogEntry {
        if let record = fetchRecord(in: modelContext, id: entry.id) {
            update(record, from: entry)
        } else {
            modelContext.insert(ExerciseLogEntryRecord(domain: entry))
        }
        saveContext()
        return entry
    }

    func delete(id: ExerciseLogEntry.ID) async {
        if let record = fetchRecord(in: modelContext, id: id) {
            modelContext.delete(record)
            saveContext()
        }
    }

    private func update(_ record: ExerciseLogEntryRecord, from entry: ExerciseLogEntry) {
        record.loggedAt = entry.loggedAt
        record.activityID = entry.activity.id
        record.activityName = entry.activity.name
        record.caloriesBurnedPerMinute = entry.activity.caloriesBurnedPerMinute?.value
        record.durationMinutes = entry.duration.value
        record.intensityRawValue = entry.intensity?.rawValue
    }

    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

@MainActor
final class SwiftDataBiometricsEntryRepository: BiometricsEntryRepository {
    private let modelContext: ModelContext
    private let calendar: Calendar

    init(modelContext: ModelContext, calendar: Calendar = .current) {
        self.modelContext = modelContext
        self.calendar = calendar
    }

    func listRecentEntries(limit: Int) async -> [BiometricsEntry] {
        guard limit > 0 else { return [] }
        return fetchRecords(
            in: modelContext,
            BiometricsEntryRecord.self,
            predicate: nil,
            sortBy: [SortDescriptor(\BiometricsEntryRecord.loggedAt, order: .reverse)],
            fetchLimit: limit
        ).compactMap(\.domainValue)
    }

    func listEntries(for date: Date) async -> [BiometricsEntry] {
        let interval = dateInterval(for: date)
        let start = interval.start
        let end = interval.end
        return fetchRecords(
            in: modelContext,
            BiometricsEntryRecord.self,
            predicate: #Predicate<BiometricsEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt < end
            },
            sortBy: [SortDescriptor(\BiometricsEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func listEntries(from startDate: Date, through endDate: Date) async -> [BiometricsEntry] {
        let start = startDate
        let end = endDate
        return fetchRecords(
            in: modelContext,
            BiometricsEntryRecord.self,
            predicate: #Predicate<BiometricsEntryRecord> {
                $0.loggedAt >= start && $0.loggedAt <= end
            },
            sortBy: [SortDescriptor(\BiometricsEntryRecord.loggedAt, order: .reverse)]
        ).compactMap(\.domainValue)
    }

    func save(_ entry: BiometricsEntry) async -> BiometricsEntry {
        if let record = fetchRecord(in: modelContext, id: entry.id) {
            update(record, from: entry)
        } else {
            modelContext.insert(BiometricsEntryRecord(domain: entry))
        }
        saveContext()
        return entry
    }

    func delete(id: BiometricsEntry.ID) async {
        if let record = fetchRecord(in: modelContext, id: id) {
            modelContext.delete(record)
            saveContext()
        }
    }

    private func update(_ record: BiometricsEntryRecord, from entry: BiometricsEntry) {
        record.loggedAt = entry.loggedAt
        record.kindRawValue = entry.kind.rawValue
        record.value = entry.value
    }

    private func dateInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }
}

private extension SwiftDataFoodLogEntryRepository {
    func saveContext() {
        try? modelContext.save()
    }
}

private extension SwiftDataExerciseLogEntryRepository {
    func saveContext() {
        try? modelContext.save()
    }
}

private extension SwiftDataBiometricsEntryRepository {
    func saveContext() {
        try? modelContext.save()
    }
}

private func fetchRecords<T: PersistentModel>(
    in context: ModelContext,
    _ type: T.Type,
    predicate: Predicate<T>? = nil,
    sortBy: [SortDescriptor<T>] = [],
    fetchLimit: Int? = nil
) -> [T] {
    var descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
    if let fetchLimit {
        descriptor.fetchLimit = fetchLimit
    }
    return (try? context.fetch(descriptor)) ?? []
}

private extension SwiftDataFoodLogEntryRepository {
    func fetchRecord(in context: ModelContext, id: UUID) -> FoodLogEntryRecord? {
        fetchRecords(
            in: context,
            FoodLogEntryRecord.self,
            predicate: #Predicate<FoodLogEntryRecord> { $0.id == id }
        ).first
    }
}

private extension SwiftDataExerciseLogEntryRepository {
    func fetchRecord(in context: ModelContext, id: UUID) -> ExerciseLogEntryRecord? {
        fetchRecords(
            in: context,
            ExerciseLogEntryRecord.self,
            predicate: #Predicate<ExerciseLogEntryRecord> { $0.id == id }
        ).first
    }
}

private extension SwiftDataBiometricsEntryRepository {
    func fetchRecord(in context: ModelContext, id: UUID) -> BiometricsEntryRecord? {
        fetchRecords(
            in: context,
            BiometricsEntryRecord.self,
            predicate: #Predicate<BiometricsEntryRecord> { $0.id == id }
        ).first
    }
}
