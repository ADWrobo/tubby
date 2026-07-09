import Foundation

struct BiometricsEntryDraft: Identifiable, Equatable, Sendable {
    enum Mode: Equatable, Sendable {
        case add
        case edit
    }

    enum ValidationError: LocalizedError, Equatable, Sendable {
        case missingValue
        case invalidNumber

        var errorDescription: String? {
            switch self {
            case .missingValue:
                return "Enter a value."
            case .invalidNumber:
                return "Value needs a valid number."
            }
        }
    }

    let id: UUID
    let mode: Mode

    var kind: BiometricsKind
    var loggedAt: Date
    var valueText: String

    init(
        id: UUID = UUID(),
        mode: Mode = .add,
        kind: BiometricsKind = .weight,
        loggedAt: Date = Date(),
        valueText: String = ""
    ) {
        self.id = id
        self.mode = mode
        self.kind = kind
        self.loggedAt = loggedAt
        self.valueText = valueText
    }

    init(entry: BiometricsEntry) {
        self.init(
            id: entry.id,
            mode: .edit,
            kind: entry.kind,
            loggedAt: entry.loggedAt,
            valueText: Self.string(from: entry.value)
        )
    }

    var isValidForSaving: Bool {
        !valueText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeEntry() throws -> BiometricsEntry {
        let value = try parseRequiredNumber(valueText)

        return BiometricsEntry(
            id: id,
            loggedAt: loggedAt,
            value: value,
            kind: kind
        )
    }

    private func parseRequiredNumber(_ text: String) throws -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.missingValue
        }
        guard let value = Double(trimmed) else {
            throw ValidationError.invalidNumber
        }
        return value
    }

    private static func string(from value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return String(value)
    }
}
