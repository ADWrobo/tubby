import Foundation

enum ManualEntryFormatting {
    static func decimalString(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }

        return value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

