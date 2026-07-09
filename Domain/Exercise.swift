import Foundation

struct Exercise: Identifiable, Equatable, Sendable {
    let id: UUID
    let loggedAt: Date
    let title: String
}
