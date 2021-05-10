import XCTest
import Foundation
@testable import Iwstb

class LineReaderTests: XCTestCase {
    private let _testLines = [
        "qwerty",
        "asdfg",
        "zxc"
    ]

    private let _dot = CharacterSet(charactersIn: ".")

    private func _getResourceFile(_ aNamed: String) -> URL? {
        guard let dotRange = aNamed.rangeOfCharacter(
                from: _dot,
                options: .backwards
                ) else {
            return nil
        }
        let name = String(aNamed[..<dotRange.lowerBound])
        let ext = String(aNamed[dotRange.upperBound...])
        return Bundle.module.url(
                forResource: name,
                withExtension: ext,
                subdirectory: "LineReaderTestData"
                )
    }

    private func _textTest(
            _ aTextFile: String,
            chomp aChomp: LineReader.Chomp? = nil
            ) {
        let u = _getResourceFile(aTextFile)!
        let reader = aChomp == nil
            ? try! Iwstb.cookLineReader(u)
            : try! Iwstb.cookLineReader(u, chomp: aChomp!)
        var i = 0
        for line in reader {
            XCTAssertLessThan(i, _testLines.count)
            guard i < _testLines.count else {
                break
            }
            XCTAssertEqual(String(line), _testLines[i])
            i += 1
        }
        XCTAssertEqual(i, _testLines.count)
    }

    func testTexts() {
        _textTest("001.txt")
        _textTest("002.txt")
        _textTest("003.txt", chomp: LineReader.Chomp.both)
    }
}
