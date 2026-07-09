import SwiftUI

struct ExerciseLogEntryFormView: View {
    enum Mode: Equatable {
        case add
        case edit

        var title: String {
            switch self {
            case .add:
                return "Add exercise"
            case .edit:
                return "Edit exercise"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (ExerciseLogEntryDraft) async throws -> Void

    @State private var draft: ExerciseLogEntryDraft
    @State private var errorMessage: String?
    @State private var isSaving = false
    @FocusState private var isActivityNameFocused: Bool

    init(
        mode: Mode,
        draft: ExerciseLogEntryDraft,
        onSave: @escaping (ExerciseLogEntryDraft) async throws -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise details") {
                    TextField("Activity name", text: $draft.activityName)
#if os(iOS)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
#endif
                        .focused($isActivityNameFocused)

                    Picker("Intensity", selection: $draft.intensity) {
                        Text("Not specified").tag(nil as ExerciseIntensity?)
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.displayName).tag(intensity as ExerciseIntensity?)
                        }
                    }
                }

                Section("Logged") {
                    DatePicker("Date and time", selection: $draft.loggedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Duration") {
                    TextField("Minutes", text: $draft.durationText)
#if os(iOS)
                        .keyboardType(.decimalPad)
#endif
                }

                Section("Energy estimate") {
                    optionalNumberField("Calories burned per minute estimate", text: $draft.caloriesBurnedPerMinuteText)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(mode.title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await save() }
                    }
                    .disabled(!draft.isValidForSaving || isSaving)
                }
            }
            .onAppear {
                if draft.activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    isActivityNameFocused = true
                }
            }
        }
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            try await onSave(draft)
            dismiss()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "We couldn't save this entry. Please try again."
        }
    }

    private func optionalNumberField(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
#if os(iOS)
            .keyboardType(.decimalPad)
#endif
    }
}

#Preview("Add Exercise Entry") {
    ExerciseLogEntryFormView(
        mode: .add,
        draft: ExerciseLogEntryDraft(
            activityName: "Walk",
            durationText: "30",
            intensity: .light
        ),
        onSave: { _ in }
    )
}

#Preview("Edit Exercise Entry") {
    ExerciseLogEntryFormView(
        mode: .edit,
        draft: ExerciseLogEntryDraft(
            entry: ExerciseLogEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000A01")!,
                loggedAt: Date(timeIntervalSince1970: 1_700_000_000),
                activity: ExerciseActivity(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000A02")!,
                    name: "Cycling",
                    caloriesBurnedPerMinute: Calories(8)
                ),
                duration: Minutes(25),
                intensity: .moderate
            )
        ),
        onSave: { _ in }
    )
}
