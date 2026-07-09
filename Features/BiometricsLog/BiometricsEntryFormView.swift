import SwiftUI

struct BiometricsEntryFormView: View {
    enum Mode: Equatable {
        case add
        case edit

        var title: String {
            switch self {
            case .add:
                return "Add measurement"
            case .edit:
                return "Edit measurement"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (BiometricsEntryDraft) async throws -> Void

    @State private var draft: BiometricsEntryDraft
    @State private var errorMessage: String?
    @State private var isSaving = false
    @FocusState private var isValueFocused: Bool

    init(
        mode: Mode,
        draft: BiometricsEntryDraft,
        onSave: @escaping (BiometricsEntryDraft) async throws -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Measurement details") {
                    Picker("Measurement type", selection: $draft.kind) {
                        ForEach(BiometricsKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                }

                Section("Logged") {
                    Text("Select when this entry was logged.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    DatePicker("Date and time", selection: $draft.loggedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Value") {
                    HStack {
                        TextField("Value", text: $draft.valueText)
#if os(iOS)
                            .keyboardType(.decimalPad)
#endif
                            .focused($isValueFocused)

                        Text(draft.kind.unitLabel)
                            .foregroundStyle(.secondary)
                    }
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
                if draft.valueText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    isValueFocused = true
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
}

#Preview("Add Biometric Entry") {
    BiometricsEntryFormView(
        mode: .add,
        draft: BiometricsEntryDraft(
            kind: .weight,
            valueText: "185"
        ),
        onSave: { _ in }
    )
}

#Preview("Edit Biometric Entry") {
    BiometricsEntryFormView(
        mode: .edit,
        draft: BiometricsEntryDraft(
            entry: BiometricsEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000A01")!,
                loggedAt: Date(timeIntervalSince1970: 1_700_000_000),
                value: 62,
                kind: .restingHeartRate
            )
        ),
        onSave: { _ in }
    )
}
