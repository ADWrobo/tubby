import SwiftUI

struct FoodLogView: View {
    @StateObject private var viewModel: FoodLogViewModel
    @State private var draft: FoodLogEntryDraft?

    init(environment: AppEnvironment) {
        self.init(repository: environment.foodLogEntryRepository)
    }

    init(repository: any FoodLogEntryRepository) {
        _viewModel = StateObject(wrappedValue: FoodLogViewModel(repository: repository))
    }

    init(viewModel: FoodLogViewModel) {
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
                    FoodLogStatusMessage(text: errorMessage)
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
                            "No recent food entries",
                            systemImage: "fork.knife",
                            description: Text("Add a food entry for this day.")
                        )
                    }
            } else {
                Section {
                    ForEach(viewModel.entries) { entry in
                        Button {
                            draft = FoodLogEntryDraft(entry: entry)
                        } label: {
                            FoodLogEntryRow(entry: entry)
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
        .navigationTitle("Food Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draft = FoodLogEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add food", systemImage: "plus")
                }
            }
        }
#else
        .listStyle(.plain)
        .navigationTitle("Food Log")
        .toolbar {
            ToolbarItem {
                Button {
                    draft = FoodLogEntryDraft(loggedAt: viewModel.selectedDate)
                } label: {
                    Label("Add food", systemImage: "plus")
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
                FoodLogEntryFormView(
                    mode: draftItem.mode == .add ? .add : .edit,
                    draft: draftItem,
                onSave: { updatedDraft in
                    try await viewModel.save(updatedDraft)
                }
            )
        }
    }

    private func delete(_ entry: FoodLogEntry) async {
        do {
            try await viewModel.delete(entry)
        } catch {
            // The view model already maps the error to calm user-facing text.
        }
    }
}

private struct FoodLogEntryRow: View {
    let entry: FoodLogEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.foodItem.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(entry.mealType.displayName) · \(servingsText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let calories = entry.foodItem.nutritionFacts.calories {
                    Text("\(calories.value, format: .number) calorie estimate")
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

    private var servingsText: String {
        if entry.servings == 1 {
            return "1 serving"
        }
        return "\(formatted(entry.servings)) servings"
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        }
        return String(value)
    }
}

private struct FoodLogStatusMessage: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}

#Preview("Empty Food Log") {
    NavigationStack {
        FoodLogView(repository: InMemoryFoodLogEntryRepository())
    }
}

#Preview("Food Log With Entries") {
    FoodLogView(repository: InMemoryFoodLogEntryRepository())
}
