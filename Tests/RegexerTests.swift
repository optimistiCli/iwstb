import XCTest
import Foundation
@testable import Iwstb

class RegexerTests: XCTestCase {
    func testInvalidRegex() {
        XCTAssertNil(Iwstb.cookRegexer(#"("#))
    }
    func testGoodRegex() {
        XCTAssertNotNil(Iwstb.cookRegexer(#"."#))
    }
    func testSuccessfulBasicRegexSearch() {
        let re = Iwstb.cookRegexer(#"."#)!
        XCTAssertNotNil(re.search("qwerty"))
    }
    func testFailedBasicRegexSearch() {
        let re = Iwstb.cookRegexer(#"."#)!
        XCTAssertNil(re.search(""))
    }
    func testRegexSearchWithParentheses() {
        let re = Iwstb.cookRegexer(#"(?<=before\s)(?:(one)|(two)|(three))(?=\safter)"#)!
        let m = re.search("This before one after that.")!
        XCTAssertEqual(m[1], "one")
        XCTAssertTrue(m[2].isEmpty)
        XCTAssertTrue(m[3].isEmpty)
    }
}
