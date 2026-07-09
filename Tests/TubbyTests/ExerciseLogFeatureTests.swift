import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct ExerciseLogFeatureTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func blankActivityNameCannotSave() {
        let draft = ExerciseLogEntryDraft(
            activityName: "   ",
            durationText: "20"
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch ExerciseLogEntryDraft.ValidationError.missingActivityName {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func nonPositiveDurationCannotSave() {
        let draft = ExerciseLogEntryDraft(
            activityName: "Walk",
            durationText: "0"
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch ExerciseLogEntryDraft.ValidationError.invalidDuration {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func blankOptionalCaloriesBurnedPerMinuteMapsToNil() throws {
        let draft = ExerciseLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000005001")!,
            activityID: UUID(uuidString: "00000000-0000-0000-0000-000000005002")!,
            activityName: "Walk",
            loggedAt: Self.day,
            durationText: "30",
            intensity: .light,
            caloriesBurnedPerMinuteText: ""
        )

        let entry = try draft.makeEntry()

        #expect(entry.activity.caloriesBurnedPerMinute == nil)
    }

    @Test func wholeAndDecimalDurationsFormatStably() {
        #expect(ManualEntryFormatting.decimalString(45) == "45")
        #expect(ManualEntryFormatting.decimalString(12.5) == "12.5")
    }

    @Test func blankDurationIsRejectedWithCalmValidation() {
        let draft = ExerciseLogEntryDraft(
            activityName: "Walk",
            durationText: "   "
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch ExerciseLogEntryDraft.ValidationError.missingDuration {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func numericCaloriesBurnedPerMinuteMapsToCalories() throws {
        let draft = ExerciseLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000005101")!,
            activityID: UUID(uuidString: "00000000-0000-0000-0000-000000005102")!,
            activityName: "Cycle",
            loggedAt: Self.day,
            durationText: "45",
            intensity: .moderate,
            caloriesBurnedPerMinuteText: "7.5"
        )

        let entry = try draft.makeEntry()

        #expect(entry.duration == Minutes(45))
        #expect(entry.activity.caloriesBurnedPerMinute == Calories(7.5))
        #expect(entry.intensity == .moderate)
    }

    @Test func editModePreservesExistingEntryAndActivityIdentity() throws {
        let entry = ExerciseLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000005201")!,
            loggedAt: Self.day,
            activity: ExerciseActivity(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005202")!,
                name: "Rowing",
                caloriesBurnedPerMinute: Calories(9)
            ),
            duration: Minutes(15),
            intensity: .vigorous
        )

        let draft = ExerciseLogEntryDraft(entry: entry)
        let rebuilt = try draft.makeEntry()

        #expect(rebuilt.id == entry.id)
        #expect(rebuilt.activity.id == entry.activity.id)
        #expect(rebuilt.activity.name == entry.activity.name)
    }

    @MainActor
    @Test func saveCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar)
        let viewModel = ExerciseLogViewModel(repository: repository, selectedDate: Self.day)

        let draft = ExerciseLogEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000005301")!,
            activityID: UUID(uuidString: "00000000-0000-0000-0000-000000005302")!,
            activityName: "Walk",
            loggedAt: Self.day,
            durationText: "35",
            intensity: .light,
            caloriesBurnedPerMinuteText: "4"
        )

        try await viewModel.save(draft)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.first?.activity.name == "Walk")
    }

    @MainActor
    @Test func deleteCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryExerciseLogEntryRepository(calendar: Self.utcCalendar)
        let existingEntry = ExerciseLogEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000005401")!,
            loggedAt: Self.day,
            activity: ExerciseActivity(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000005402")!,
                name: "Yoga",
                caloriesBurnedPerMinute: nil
            ),
            duration: Minutes(40),
            intensity: .light
        )
        _ = try await repository.save(existingEntry)

        let viewModel = ExerciseLogViewModel(repository: repository, selectedDate: Self.day)
        await viewModel.loadEntries()
        #expect(viewModel.entries == [existingEntry])

        try await viewModel.delete(existingEntry)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.isEmpty)
    }

    @Test func estimatedCaloriesUseDurationAndCaloriesBurnedPerMinute() throws {
        let draft = ExerciseLogEntryDraft(
            activityName: "Run",
            loggedAt: Self.day,
            durationText: "12.5",
            intensity: .vigorous,
            caloriesBurnedPerMinuteText: "10"
        )

        let entry = try draft.makeEntry()

        #expect(entry.estimatedCaloriesBurned() == Calories(125))
    }
}
