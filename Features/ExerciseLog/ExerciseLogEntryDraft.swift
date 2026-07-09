import Foundation

struct ExerciseLogEntryDraft: Identifiable, Equatable, Sendable {
    enum Mode: Equatable, Sendable {
        case add
        case edit
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case missingActivityName
        case missingDuration
        case invalidDuration
        case invalidNumber(field: String)

        var errorDescription: String? {
            switch self {
            case .missingActivityName:
                return "Enter an activity name."
            case .missingDuration:
                return "Enter minutes for this entry."
            case .invalidDuration:
                return "Duration needs to be greater than 0."
            case .invalidNumber(let field):
                return "Enter a valid number for \(field), or leave it blank."
            }
        }
    }

    let id: UUID
    let activityID: UUID
    let mode: Mode

    var activityName: String
    var loggedAt: Date
    var durationText: String
    var intensity: ExerciseIntensity?
    var caloriesBurnedPerMinuteText: String

    init(
        id: UUID = UUID(),
        activityID: UUID = UUID(),
        mode: Mode = .add,
        activityName: String = "",
        loggedAt: Date = Date(),
        durationText: String = "",
        intensity: ExerciseIntensity? = nil,
        caloriesBurnedPerMinuteText: String = ""
    ) {
        self.id = id
        self.activityID = activityID
        self.mode = mode
        self.activityName = activityName
        self.loggedAt = loggedAt
        self.durationText = durationText
        self.intensity = intensity
        self.caloriesBurnedPerMinuteText = caloriesBurnedPerMinuteText
    }

    init(entry: ExerciseLogEntry) {
        self.init(
            id: entry.id,
            activityID: entry.activity.id,
            mode: .edit,
            activityName: entry.activity.name,
            loggedAt: entry.loggedAt,
            durationText: Self.string(from: entry.duration.value),
            intensity: entry.intensity,
            caloriesBurnedPerMinuteText: Self.string(from: entry.activity.caloriesBurnedPerMinute?.value)
        )
    }

    var isValidForSaving: Bool {
        !activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !durationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeEntry() throws -> ExerciseLogEntry {
        let trimmedActivityName = activityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedActivityName.isEmpty else {
            throw ValidationError.missingActivityName
        }

        let trimmedDuration = durationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDuration.isEmpty else {
            throw ValidationError.missingDuration
        }

        let duration = try parseRequiredNumber(durationText, field: "Duration")
        guard duration > 0 else {
            throw ValidationError.invalidDuration
        }

        return ExerciseLogEntry(
            id: id,
            loggedAt: loggedAt,
            activity: ExerciseActivity(
                id: activityID,
                name: trimmedActivityName,
                caloriesBurnedPerMinute: try parseOptionalNumber(
                    caloriesBurnedPerMinuteText,
                    field: "Calories burned per minute",
                    wrap: Calories.init
                )
            ),
            duration: Minutes(duration),
            intensity: intensity
        )
    }

    private func parseRequiredNumber(_ text: String, field: String) throws -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed) else {
            throw ValidationError.invalidNumber(field: field)
        }
        return value
    }

    private func parseOptionalNumber<T>(
        _ text: String,
        field: String,
        wrap: (Double) -> T
    ) throws -> T? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        guard let value = Double(trimmed) else {
            throw ValidationError.invalidNumber(field: field)
        }
        return wrap(value)
    }

    private static func string(from value: Double?) -> String {
        guard let value else { return "" }
        return string(from: value)
    }

    private static func string(from value: Double) -> String {
        ManualEntryFormatting.decimalString(value)
    }
}

extension ExerciseIntensity {
    var displayName: String {
        rawValue.capitalized
    }
}
