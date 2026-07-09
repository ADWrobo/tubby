import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct BiometricsLogFeatureTests {
    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let day = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func blankValueCannotSave() {
        let draft = BiometricsEntryDraft(
            kind: .weight,
            valueText: "   "
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch BiometricsEntryDraft.ValidationError.missingValue {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func invalidNumericValueCannotSave() {
        let draft = BiometricsEntryDraft(
            kind: .weight,
            valueText: "abc"
        )

        do {
            _ = try draft.makeEntry()
            #expect(Bool(false))
        } catch BiometricsEntryDraft.ValidationError.invalidNumber {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func wholeAndDecimalMeasurementValuesFormatStably() {
        #expect(ManualEntryFormatting.decimalString(118) == "118")
        #expect(ManualEntryFormatting.decimalString(34.5) == "34.5")
    }

    @Test func validValueAndKindMapToEntry() throws {
        let draft = BiometricsEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000006001")!,
            kind: .restingHeartRate,
            loggedAt: Self.day,
            valueText: "62"
        )

        let entry = try draft.makeEntry()

        #expect(entry.id == draft.id)
        #expect(entry.loggedAt == Self.day)
        #expect(entry.value == 62)
        #expect(entry.kind == .restingHeartRate)
    }

    @Test func editModePreservesExistingEntryIdentity() throws {
        let entry = BiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000006101")!,
            loggedAt: Self.day,
            value: 118,
            kind: .systolicBloodPressure
        )

        let draft = BiometricsEntryDraft(entry: entry)
        let rebuilt = try draft.makeEntry()

        #expect(rebuilt.id == entry.id)
        #expect(rebuilt.loggedAt == entry.loggedAt)
        #expect(rebuilt.kind == entry.kind)
        #expect(rebuilt.value == entry.value)
    }

    @MainActor
    @Test func saveCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar)
        let viewModel = BiometricsLogViewModel(repository: repository, selectedDate: Self.day)

        let draft = BiometricsEntryDraft(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000006201")!,
            kind: .waistMeasurement,
            loggedAt: Self.day,
            valueText: "34.5"
        )

        try await viewModel.save(draft)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.first?.kind == .waistMeasurement)
        #expect(viewModel.entries.first?.value == 34.5)
    }

    @MainActor
    @Test func deleteCallsRepositoryAndRefreshesEntries() async throws {
        let repository = InMemoryBiometricsEntryRepository(calendar: Self.utcCalendar)
        let existingEntry = BiometricsEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000006301")!,
            loggedAt: Self.day,
            value: 78,
            kind: .diastolicBloodPressure
        )
        _ = try await repository.save(existingEntry)

        let viewModel = BiometricsLogViewModel(repository: repository, selectedDate: Self.day)
        await viewModel.loadEntries()
        #expect(viewModel.entries == [existingEntry])

        try await viewModel.delete(existingEntry)

        let storedEntries = try await repository.listEntries(for: Self.day)
        #expect(viewModel.entries == storedEntries)
        #expect(viewModel.entries.isEmpty)
    }

    @Test func unitLabelsAndDisplayNamesAreStable() {
        #expect(BiometricsKind.weight.displayName == "Weight")
        #expect(BiometricsKind.weight.unitLabel == "lb")
        #expect(BiometricsKind.systolicBloodPressure.displayName == "Systolic blood pressure")
        #expect(BiometricsKind.systolicBloodPressure.unitLabel == "mmHg")
        #expect(BiometricsKind.diastolicBloodPressure.displayName == "Diastolic blood pressure")
        #expect(BiometricsKind.diastolicBloodPressure.unitLabel == "mmHg")
        #expect(BiometricsKind.restingHeartRate.displayName == "Resting heart rate")
        #expect(BiometricsKind.restingHeartRate.unitLabel == "bpm")
        #expect(BiometricsKind.waistMeasurement.displayName == "Waist measurement")
        #expect(BiometricsKind.waistMeasurement.unitLabel == "in")
    }
}
