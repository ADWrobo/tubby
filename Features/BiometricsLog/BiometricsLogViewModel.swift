import Foundation
import Combine

@MainActor
final class BiometricsLogViewModel: ObservableObject {
    // The repository can be backed by either an actor or a @MainActor SwiftData service.
    // Keep a nonisolated reference so the main-actor model can await it without extra wrappers.
    nonisolated(unsafe) let repository: any BiometricsEntryRepository

    @Published var selectedDate: Date
    @Published var entries: [BiometricsEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(
        repository: any BiometricsEntryRepository,
        selectedDate: Date = Date()
    ) {
        self.repository = repository
        self.selectedDate = selectedDate
    }

    func loadEntries() async {
        isLoading = true
        defer { isLoading = false }

        do {
            entries = try await repository.listEntries(for: selectedDate)
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            errorMessage = BiometricsLogViewError.load.localizedDescription
        }
    }

    func save(_ draft: BiometricsEntryDraft) async throws {
        do {
            let entry = try draft.makeEntry()
            _ = try await repository.save(entry)
            try await refreshEntries()
            errorMessage = nil
        } catch let validation as BiometricsEntryDraft.ValidationError {
            errorMessage = validation.localizedDescription
            throw validation
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            let operationError = BiometricsLogViewError.save
            errorMessage = operationError.localizedDescription
            throw operationError
        }
    }

    func delete(_ entry: BiometricsEntry) async throws {
        do {
            try await repository.delete(id: entry.id)
            try await refreshEntries()
            errorMessage = nil
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            let operationError = BiometricsLogViewError.delete
            errorMessage = operationError.localizedDescription
            throw operationError
        }
    }

    private func refreshEntries() async throws {
        entries = try await repository.listEntries(for: selectedDate)
    }
}

private enum BiometricsLogViewError: LocalizedError {
    case load
    case save
    case delete

    var errorDescription: String? {
        switch self {
        case .load:
            return "We couldn't load recent biometrics entries. Please try again."
        case .save:
            return "We couldn't save this entry. Please try again."
        case .delete:
            return "We couldn't delete this entry. Please try again."
        }
    }
}
