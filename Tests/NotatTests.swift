
import XCTest
@testable import Notat

final class NotatTests: XCTestCase {
    func testTerminSort() throws {
        let now = Date()
        let a = TerminItem(title: "A", dateTime: now.addingTimeInterval(3600))
        let b = TerminItem(title: "B", dateTime: now.addingTimeInterval(-3600))
        let c = TerminItem(title: "C", dateTime: now.addingTimeInterval(7200), isCompleted: true)
        let sorted = TerminViewModel.sort([a,b,c])
        XCTAssertEqual(sorted.first?.title, "B")
        XCTAssertEqual(sorted.last?.isCompleted, true)
    }
}
