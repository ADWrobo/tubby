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
