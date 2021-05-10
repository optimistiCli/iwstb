import XCTest
@testable import Iwstb

class IwstbTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(Iwstb().version, "0.1.0")
    }
}
