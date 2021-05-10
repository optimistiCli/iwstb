/**
 Handy extensions to String, Substring and such.
 */
import Foundation

public extension StringProtocol {
    /**
     Evaluates to nil if the String or Substring is empty.
     */
    var emptyIsNil: Self? {
        isEmpty
            ? nil
            : self
    }
}

public extension Chompable {
    /**
     Substring without any trailing whitespaces as in
     [NSCharacterSet.whitespacesAndNewlines](apple-reference-documentation://ls%2Fdocumentation%2Ffoundation%2Fnscharacterset%2F1413732-whitespacesandnewlines)
     or nil if the String or Substring is empty or consists only of whitespaces.
     */
    var chompedTrailing: Substring? {
        guard let trailingRange = self.rangeOfCharacter(
                from: _notWhitespacesandnewlines,
                options: .backwards
                ) else {
            return nil
        }
        // TODO: Try using upperBound
        let range = ..<index(after: trailingRange.lowerBound)
        return Substring(self[range])
    }

    /**
     Substring without any leading whitespaces as in
     [NSCharacterSet.whitespacesAndNewlines](apple-reference-documentation://ls%2Fdocumentation%2Ffoundation%2Fnscharacterset%2F1413732-whitespacesandnewlines)
     or nil if the String or Substring is empty or consists only of whitespaces.
     */
    var chompedLeading: Substring? {
        guard let leadingRange = self.rangeOfCharacter(
                from: _notWhitespacesandnewlines
                ) else {
            return nil
        }
        let range = leadingRange.lowerBound...
        return Substring(self[range])
    }

    /**
     Substring without any leading or trailing whitespaces as in
     [NSCharacterSet.whitespacesAndNewlines](apple-reference-documentation://ls%2Fdocumentation%2Ffoundation%2Fnscharacterset%2F1413732-whitespacesandnewlines)
     or nil if the String or Substring is empty or consists only of whitespaces.
     */
    var chompedBoth: Substring? {
        guard let leadingRange = self.rangeOfCharacter(
                from: _notWhitespacesandnewlines
                ) else {
            return nil
        }
        guard let trailingRange = self.rangeOfCharacter(
                from: _notWhitespacesandnewlines,
                options: .backwards
                ) else {
            return nil
        }
        let range = leadingRange.lowerBound..<index(after: trailingRange.lowerBound)
        return Substring(self[range])
    }
}

// MARK: Implementation artifacts
fileprivate let _notWhitespacesandnewlines
        = NSCharacterSet.whitespacesAndNewlines.inverted

/**
 A regrettable implementation artefact
 */
public protocol Chompable: StringProtocol {
    var chompedTrailing: Substring? { get }
    var chompedLeading: Substring? { get }
    var chompedBoth: Substring? { get }
}

/**
 A regrettable implementation artefact
 */
extension String: Chompable {}

/**
 A regrettable implementation artefact
 */
extension Substring: Chompable {}
