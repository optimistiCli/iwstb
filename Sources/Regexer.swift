import Foundation

/**
 Convenience wrapper for the  `NSRegularExpression`

 Please see `cookRegexer` in `Iwstb` for more docs.
 */
public class Regexer {
    private let _regex: NSRegularExpression

    internal init(
            _ aPattern: String,
            options aOptions: NSRegularExpression.Options = []
            ) throws {
        _regex = try NSRegularExpression(
                pattern: aPattern,
                options: aOptions
                )
    }

    /* ***
     * Every attempt is made here not to make copies of any part of the
     * original string
     */
    private class _MatchesSeq: Sequence, IteratorProtocol {
        private let _str: String
        private let _match: NSTextCheckingResult
        private let _count: Int
        private var _i: Int
        private var _exhausted: Bool

        private lazy var _zeroSubstring = _str[..<String.Index(utf16Offset: 0, in: _str)]

        init(_ aMatch: NSTextCheckingResult, _ aStr: String) {
            _str = aStr
            _match = aMatch
            _count = aMatch.numberOfRanges
            _i = 0
            _exhausted = false
        }

        func next() -> Substring? {
            if _exhausted {
                return nil
            }
            if (_i == _count) {
                _exhausted = true
                return nil
            }
            defer { _i += 1 }
            guard let range = Range(_match.range(at: _i), in: _str) else {
                return _zeroSubstring
            }
            return _str[range]
        }
    }

    /**
     
     - Parameters:
       - aStr: A string where this regexp will search for a match.

     - Returns: An array of substrings of the original string. First element corresponds to the the pattern
                as a whole. Second and further substrings consist of the matches of the capturing
                groups. If certain gorup did not match anything then the corresponding subscting
                is empty.
     */
    public func search(_ aStr: String) -> [Substring]? {
        if let match = _regex.firstMatch(
                in: aStr,
                options: [],
                range: NSRange(location: 0, length: aStr.utf16.count)
                ) {
            let ret = Array(_MatchesSeq(match, aStr))
            return ret
        } else {
            return nil
        }
    }

    // TODO: Add replace
    // TODO: Add search again
}
