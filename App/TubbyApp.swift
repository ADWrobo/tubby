import SwiftUI

@main
struct TubbyApp: App {
    let environment = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            TodayView(environment: environment)
        }
    }
}
