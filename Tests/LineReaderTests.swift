import XCTest
import Foundation
@testable import Iwstb

class LineReaderTests: XCTestCase {
    private let _testDirPath: String = {
        let source = #file
        var cs = CharacterSet()
        cs.insert("/")
        let lastSlashIndex = source.rangeOfCharacter(
            from: cs,
            options: String.CompareOptions.backwards
            )!.upperBound
        return String(source[..<lastSlashIndex])
    }()

    private let _testLines = [
        "qwerty",
        "asdfg",
        "zxc"
    ]

    private func _getAlongsideFile(_ aNamed: String) -> URL {
        return URL(fileURLWithPath: _testDirPath + aNamed)
    }

    private func _textTest(
            _ aTextFile: String,
            chomp aChomp: LineReader.Chomp? = nil
            ) {
        let reader = aChomp == nil
            ? try! Iwstb.cookLineReader(
                _getAlongsideFile(aTextFile))
            : try! Iwstb.cookLineReader(
                _getAlongsideFile(aTextFile),
                chomp: aChomp!
                )
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
        _textTest("LineReaderTestText001.txt")
        _textTest("LineReaderTestText002.txt")
        _textTest("LineReaderTestText003.txt", chomp: LineReader.Chomp.both)
    }
}
