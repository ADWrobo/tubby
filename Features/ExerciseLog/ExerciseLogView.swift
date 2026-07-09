import SwiftUI

struct ExerciseLogView: View {
    @StateObject private var viewModel: ExerciseLogViewModel
    @State private var draft: ExerciseLogEntryDraft?

    init(environment: AppEnvironment) {
        self.init(repository: environment.exerciseLogEntryRepository)
    }

    init(repository: any ExerciseLogEntryRepository) {
        _viewModel = StateObject(wrappedValue: ExerciseLogViewModel(repository: repository))
    }

    init(viewModel: ExerciseLogViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                DatePicker("Day", selection: $viewModel.selectedDate, displayedComponents: [.date])
            } header: {
                Text("Date")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    ExerciseLogStatusMessage(text: errorMessage)
                }
            }

            if viewModel.isLoading && viewModel.entries.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Loading entries")
                        Spacer()
                    }
                }
            } else if viewModel.entries.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No exercise entries yet",
                        systemImage: "figure.walk",
                        description: Text("Add an activity for this day.")
                    )
                }
            } else {
                Section {
                    ForEach(viewModel.entries) { entry in
                        Button {
                            draft = ExerciseLogEntryDraft(entry: entry)
                        } label: {
                            ExerciseLogEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
#if os(iOS)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await delete(entry) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
#endif
                    }
                }
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
        .navigationTitle("Exercise Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draft = ExerciseLogEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
#else
        .listStyle(.plain)
        .navigationTitle("Exercise Log")
        .toolbar {
            ToolbarItem {
                Button {
                    draft = ExerciseLogEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
#endif
        .task(id: viewModel.selectedDate) {
            await viewModel.loadEntries()
        }
        .sheet(item: $draft, onDismiss: {
            draft = nil
        }) { draftItem in
            ExerciseLogEntryFormView(
                mode: draftItem.mode == .add ? .add : .edit,
                draft: draftItem,
                onSave: { updatedDraft in
                    try await viewModel.save(updatedDraft)
                }
            )
        }
    }

    private func delete(_ entry: ExerciseLogEntry) async {
        do {
            try await viewModel.delete(entry)
        } catch {
            // The view model already maps the error to calm user-facing text.
        }
    }
}

private struct ExerciseLogEntryRow: View {
    let entry: ExerciseLogEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.activity.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(detailText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let calories = entry.estimatedCaloriesBurned() {
                    Text("\(formatted(calories.value)) estimated calories")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(entry.loggedAt, style: .time)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var detailText: String {
        var parts = ["\(formatted(entry.duration.value)) minutes"]
        if let intensity = entry.intensity {
            parts.append(intensity.displayName)
        }
        return parts.joined(separator: " · ")
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

private struct ExerciseLogStatusMessage: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}

#Preview("Empty Exercise Log") {
    NavigationStack {
        ExerciseLogView(repository: InMemoryExerciseLogEntryRepository())
    }
}

#Preview("Exercise Log With Entries") {
    ExerciseLogView(repository: InMemoryExerciseLogEntryRepository())
}
