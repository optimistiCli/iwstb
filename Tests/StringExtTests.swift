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

    func testEnvNames() {
        var str = "A1"
        XCTAssertTrue(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "A_1"
        XCTAssertTrue(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "_A1"
        XCTAssertTrue(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = ""
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertFalse(str.isAllowedEnvironmentVariableName)

        str = "A\u{001B}1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertFalse(str.isAllowedEnvironmentVariableName)

        str = "A\u{0000}1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertFalse(str.isAllowedEnvironmentVariableName)

        str = "A=1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertFalse(str.isAllowedEnvironmentVariableName)

        str = "A¿1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertFalse(str.isAllowedEnvironmentVariableName)

        str = "1A"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "1a"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertFalse(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "a1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "a_1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

        str = "_a1"
        XCTAssertFalse(str.isStrictlyValidEnvironmentVariableName)
        XCTAssertTrue(str.isValidEnvironmentVariableName)
        XCTAssertTrue(str.isAllowedEnvironmentVariableName)

    }
}
