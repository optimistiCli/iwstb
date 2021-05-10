import XCTest
import Foundation
@testable import Iwstb

class StringExtTests: XCTestCase {
    func testEmptyIsNil() {
        XCTAssertNil("".emptyIsNil)
        XCTAssertNotNil("str".emptyIsNil)
    }

    func testChomps() {
        var str = "str"
        XCTAssertEqual(str.chompedTrailing, "str")
        XCTAssertEqual(str.chompedLeading, "str")
        XCTAssertEqual(str.chompedBoth, "str")

        str = " str"
        XCTAssertEqual(str.chompedTrailing, " str")
        XCTAssertEqual(str.chompedLeading, "str")
        XCTAssertEqual(str.chompedBoth, "str")

        str = "\tstr"
        XCTAssertEqual(str.chompedTrailing, "\tstr")
        XCTAssertEqual(str.chompedLeading, "str")
        XCTAssertEqual(str.chompedBoth, "str")

        str = " \t\r\nstr"
        XCTAssertEqual(str.chompedTrailing, " \t\r\nstr")
        XCTAssertEqual(str.chompedLeading, "str")
        XCTAssertEqual(str.chompedBoth, "str")

        str = "str "
        XCTAssertEqual(str.chompedTrailing, "str")
        XCTAssertEqual(str.chompedLeading, "str ")
        XCTAssertEqual(str.chompedBoth, "str")

        str = "str\t"
        XCTAssertEqual(str.chompedTrailing, "str")
        XCTAssertEqual(str.chompedLeading, "str\t")
        XCTAssertEqual(str.chompedBoth, "str")

        str = "str \t\r\n"
        XCTAssertEqual(str.chompedTrailing, "str")
        XCTAssertEqual(str.chompedLeading, "str \t\r\n")
        XCTAssertEqual(str.chompedBoth, "str")
    }
}
