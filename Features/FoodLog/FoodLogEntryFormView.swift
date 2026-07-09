import SwiftUI

struct FoodLogEntryFormView: View {
    enum Mode: Equatable {
        case add
        case edit

        var title: String {
            switch self {
            case .add:
                return "Add food"
            case .edit:
                return "Edit food"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (FoodLogEntryDraft) async throws -> Void

    @State private var draft: FoodLogEntryDraft
    @State private var errorMessage: String?
    @State private var isSaving = false
    @FocusState private var isFoodNameFocused: Bool

    init(
        mode: Mode,
        draft: FoodLogEntryDraft,
        onSave: @escaping (FoodLogEntryDraft) async throws -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Food details") {
                    TextField("Food name", text: $draft.foodName)
#if os(iOS)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
#endif
                        .focused($isFoodNameFocused)

                    Picker("Meal type", selection: $draft.mealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.displayName).tag(mealType)
                        }
                    }
                }

                Section("Logged") {
                    Text("Select when this entry was logged.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    DatePicker("Date and time", selection: $draft.loggedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Amount") {
                    TextField("Servings", text: $draft.servingsText)
#if os(iOS)
                        .keyboardType(.decimalPad)
#endif
                }

                Section("Nutrition estimate") {
                    optionalNumberField("Calorie estimate", text: $draft.caloriesText)
                    optionalNumberField("Protein estimate (g)", text: $draft.proteinText)
                    optionalNumberField("Carbohydrates estimate (g)", text: $draft.carbohydratesText)
                    optionalNumberField("Fat estimate (g)", text: $draft.fatText)
                    optionalNumberField("Fiber estimate (g)", text: $draft.fiberText)
                    optionalNumberField("Sugar estimate (g)", text: $draft.sugarText)
                    optionalNumberField("Sodium estimate (mg)", text: $draft.sodiumText)
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
                if draft.foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    isFoodNameFocused = true
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

#Preview("Add Food Entry") {
    FoodLogEntryFormView(
        mode: .add,
        draft: FoodLogEntryDraft(
            foodName: "Apple",
            mealType: .snack
        ),
        onSave: { _ in }
    )
}

#Preview("Edit Food Entry") {
    FoodLogEntryFormView(
        mode: .edit,
        draft: FoodLogEntryDraft(
            entry: FoodLogEntry(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000901")!,
                loggedAt: Date(timeIntervalSince1970: 1_700_000_000),
                mealType: .lunch,
                foodItem: FoodItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000902")!,
                    name: "Chicken salad",
                    nutritionFacts: NutritionFacts(
                        calories: Calories(320),
                        protein: Grams(24),
                        carbohydrates: Grams(12),
                        fat: Grams(18)
                    )
                ),
                servings: 1
            )
        ),
        onSave: { _ in }
    )
}
