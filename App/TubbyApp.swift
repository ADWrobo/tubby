import SwiftUI
import SwiftData

@MainActor
@main
struct TubbyApp: App {
    private let modelContainer: ModelContainer
    private let environment: AppEnvironment

    init() {
        let container = Self.makeModelContainer()
        modelContainer = container
        environment = AppEnvironment.live(modelContext: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            TodayView(environment: environment)
        }
    }

    private static func makeModelContainer() -> ModelContainer {
        try! ModelContainer(
            for: FoodLogEntryRecord.self,
            ExerciseLogEntryRecord.self,
            BiometricsEntryRecord.self
        )
    }
}
