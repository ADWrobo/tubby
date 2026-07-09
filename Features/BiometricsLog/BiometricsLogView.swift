import SwiftUI

struct BiometricsLogView: View {
    @StateObject private var viewModel: BiometricsLogViewModel
    @State private var draft: BiometricsEntryDraft?

    init(environment: AppEnvironment) {
        self.init(repository: environment.biometricsEntryRepository)
    }

    init(repository: any BiometricsEntryRepository) {
        _viewModel = StateObject(wrappedValue: BiometricsLogViewModel(repository: repository))
    }

    init(viewModel: BiometricsLogViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                DatePicker("Recent day", selection: $viewModel.selectedDate, displayedComponents: [.date])
            } header: {
                Text("Recent")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    BiometricsLogStatusMessage(text: errorMessage)
                }
            }

            if viewModel.isLoading && viewModel.entries.isEmpty {
                Section {
                        HStack {
                            Spacer()
                        ProgressView("Loading recent entries")
                            Spacer()
                        }
                    }
                } else if viewModel.entries.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No recent biometrics entries",
                            systemImage: "heart.text.square",
                            description: Text("Add a biometrics entry for this day.")
                        )
                    }
            } else {
                Section {
                    ForEach(viewModel.entries) { entry in
                        Button {
                            draft = BiometricsEntryDraft(entry: entry)
                        } label: {
                            BiometricsLogEntryRow(entry: entry)
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
        .navigationTitle("Biometrics Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draft = BiometricsEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add measurement", systemImage: "plus")
                }
            }
        }
#else
        .listStyle(.plain)
        .navigationTitle("Biometrics Log")
        .toolbar {
            ToolbarItem {
                Button {
                    draft = BiometricsEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add measurement", systemImage: "plus")
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
            BiometricsEntryFormView(
                mode: draftItem.mode == .add ? .add : .edit,
                draft: draftItem,
                onSave: { updatedDraft in
                    try await viewModel.save(updatedDraft)
                }
            )
        }
    }

    private func delete(_ entry: BiometricsEntry) async {
        do {
            try await viewModel.delete(entry)
        } catch {
            // The view model already maps the error to calm user-facing text.
        }
    }
}

private struct BiometricsLogEntryRow: View {
    let entry: BiometricsEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.kind.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(formatted(entry.value)) \(entry.kind.unitLabel)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(entry.loggedAt, style: .time)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

private struct BiometricsLogStatusMessage: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}

#Preview("Empty Biometrics Log") {
    NavigationStack {
        BiometricsLogView(repository: InMemoryBiometricsEntryRepository())
    }
}

#Preview("Biometrics Log With Entries") {
    BiometricsLogView(repository: InMemoryBiometricsEntryRepository())
}
