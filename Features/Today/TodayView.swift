import SwiftUI

struct TodayView: View {
    let environment: AppEnvironment

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today")
                            .font(.largeTitle.bold())
                        Text("A calm, local-first summary of recent logs.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        FoodLogView(repository: environment.foodLogEntryRepository)
                    } label: {
                        ActionCard(
                            title: "Food Log",
                            detail: "Add and review meals for the selected day."
                        )
                    }
                    .buttonStyle(.plain)

                    SummaryCard(title: "Meals", detail: "No meals logged yet.")
                    SummaryCard(title: "Exercise", detail: "No exercise logged yet.")
                    SummaryCard(title: "Biometrics", detail: "No biometrics logged yet.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Tubby")
        }
    }
}

private struct ActionCard: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SummaryCard: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
