import Foundation

struct Meal: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let title: String
}
