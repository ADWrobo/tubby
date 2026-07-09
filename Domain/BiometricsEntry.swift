import Foundation

struct BiometricsEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let value: Double
    let kind: String
}
