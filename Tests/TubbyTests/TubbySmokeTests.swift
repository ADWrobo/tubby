import Foundation
import Testing

#if canImport(Tubby)
@testable import Tubby
#elseif canImport(TubbyCore)
@testable import TubbyCore
#endif

struct TubbySmokeTests {
    @Test func mealModelStoresValues() {
        let meal = Meal(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, loggedAt: .distantPast, title: "Breakfast")

        #expect(meal.title == "Breakfast")
        #expect(meal.loggedAt == .distantPast)
    }
}
