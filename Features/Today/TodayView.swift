import SwiftUI

struct TodayView: View {
    let environment: AppEnvironment
    @StateObject private var viewModel: TodayViewModel

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: TodayViewModel(environment: environment))
    }

    init(environment: AppEnvironment, viewModel: TodayViewModel) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today")
                            .font(.largeTitle.bold())
                        Text("A calm, local-first summary of recent entries.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        FoodLogView(environment: environment)
                    } label: {
                        ActionCard(
                            title: "Food Log",
                            detail: "Review recent food entries and details."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ExerciseLogView(environment: environment)
                    } label: {
                        ActionCard(
                            title: "Exercise Log",
                            detail: "Review recent exercise entries and details."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        BiometricsLogView(environment: environment)
                    } label: {
                        ActionCard(
                            title: "Biometrics Log",
                            detail: "Review recent measurement entries and details."
                        )
                    }
                    .buttonStyle(.plain)

                    if viewModel.isLoading && !viewModel.hasLoaded {
                        LoadingSummaryCard()
                    }

                    if let errorMessage = viewModel.errorMessage {
                        SummaryCard(title: "Summary", lines: [errorMessage], systemImage: "exclamationmark.circle")
                    }

                    SummaryCard(title: "Food summary", lines: viewModel.mealSummaryLines, systemImage: "fork.knife")
                    SummaryCard(title: "Exercise summary", lines: viewModel.exerciseSummaryLines, systemImage: "figure.walk")
                    SummaryCard(title: "Biometrics summary", lines: viewModel.biometricsSummaryLines, systemImage: "heart.text.square")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Tubby")
            .task {
                await viewModel.loadSummary()
            }
            .onAppear {
                guard viewModel.hasLoaded else { return }
                Task {
                    await viewModel.refresh()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
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
    let lines: [String]
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct LoadingSummaryCard: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Loading today's summary...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
