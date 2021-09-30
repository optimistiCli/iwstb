/**
 * Handy extensions to String, Substring and such.
 */
import Foundation

public extension StringProtocol {
    /**
     * Evaluates to nil if the String or Substring is empty.
     */
    var emptyIsNil: Self? {
        isEmpty
            ? nil
            : self
    }

    /**
     * - Returns: Parsed `Double` or `nil`.
     */
    var asDouble: Double? {
        Double(self)
    }

    /**
     * - Returns: Parsed `Int` or `nil`.
     */
    var asInt: Int? {
        Int(self)
    }

    /**
     * - Returns: Parsed `CGFloat` or `nil`.
     */
    var asCgfloat: CGFloat? {
        guard let d = Double(self) else {
            return nil
        }
        return CGFloat(d)
    }
}

// MARK: Indentation
public extension StringProtocol {
    /**
     * Returns `String` that has every line prepended with given `String`. Assumes Unix EOLs.
     *
     * - Parameters:
     *   - aIndent: Indentation prefix
     *   .
     * - Returns: Indented string.
     */
    func indented(with aIndent: String) -> String {
        return aIndent + String(reduce(into: [Character]()) { buffer, char in
            buffer.append(char)
            if char == "\n" {
                for indentChar in aIndent {
                    buffer.append(indentChar)
                }
            }
        })
    }

    /**
     * - Returns: Every line indented with a single \t.
     */
    var indentedWithTab: String {
        indented(with: "\t")
    }

    /**
     * - Returns: Every line indented with two whitespaces.
     */
    var indentedWith2Spaces: String {
        indented(with: "  ")
    }

    /**
     * - Returns: Every line indented with four whitespaces.
     */
    var indentedWith4Spaces: String {
        indented(with: "    ")
    }

    /**
     * - Returns: Every line indented with eight whitespaces.
     */
    var indentedWith8Spaces: String {
        indented(with: "        ")
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

    func removingLast(_ aNum: Int) -> Substring? {
        return aNum > count
            ? nil
            : (self[startIndex ..< index(endIndex, offsetBy: -aNum)] as! Substring)
    }
}


// MARK: Environment Variable Names
/**
 * Helpers for dealing with environment variables. Lagerly based on this answer:
 * https://stackoverflow.com/a/2821183/5272636
 *
 * > … names shall not contain the character '='. For values to be portable across systems conforming to
 * > POSIX.1-2017, the value shall be composed of characters from the portable character set (except NUL
 * > and as indicated below)
 * > …
 * > Environment variable names used by the utilities in the Shell and Utilities volume of POSIX.1-2017
 * > consist solely of uppercase letters, digits, and the <underscore> ( '_' ) from the characters defined
 * > in Portable Character Set and do not begin with a digit. Other characters may be permitted by an
 * > implementation; applications shall tolerate the presence of such names. Uppercase and lowercase
 * > letters shall retain their unique identities and shall not be folded together.
 * > …
 * > Note: Other applications may have difficulty dealing with environment variable names that start with a
 * > digit. For this reason, use of such names is not recommended anywhere.
 * Source: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
 */
public extension String {
    private static let _strictlyVarlidRe = Iwstb.cookRegexer(#"^[A-Z_][A-Z_0-9]*$"#)!
    private static let _varlidRe = Iwstb.cookRegexer(#"^[A-Za-z_][A-Za-z_0-9]*$"#)!
    private static let _allowedChars = CharacterSet.portable
            .subtracting(CharacterSet([
                Unicode.Scalar(0x0000),
                "=",
            ]))

    /**
     * The rule Open Group's own software adhere to when setting environment variables.
     */
    var isStrictlyValidEnvironmentVariableName: Bool {
        Self._strictlyVarlidRe.search(self) != nil
    }

    /**
     * Most commonly used rule for environment variable naming
     */
    var isValidEnvironmentVariableName: Bool {
        Self._varlidRe.search(self) != nil
    }

    /**
     * The most permissive rule for environment variable naming. Will let thru names that can break stuff.
     */
    var isAllowedEnvironmentVariableName: Bool {
        self.count > 0 && self.conforms(to: Self._allowedChars)
    }
}


// MARK: Character Set
public extension StringProtocol {
    /**
     * Reterns true if all characters in the (sub)string belong to given charset.
     */
    @inlinable func conforms(to aCharset: CharacterSet) -> Bool {
        for char in self.unicodeScalars {
            guard aCharset.contains(char) else {
                return false
            }
        }
        return true
    }
}


// MARK: Implementation artifacts
fileprivate let _notWhitespacesandnewlines
        = NSCharacterSet.whitespacesAndNewlines.inverted

/**
 * :nodoc:
 * A regrettable implementation artefact
 */
public protocol Chompable: StringProtocol {
    var chompedTrailing: Substring? { get }
    var chompedLeading: Substring? { get }
    var chompedBoth: Substring? { get }
    func removingLast(_ aNum: Int) -> Substring?
}

/**
 * :nodoc:
 * A regrettable implementation artefact
 */
extension String: Chompable {
    /**
     A convenience unwrapper for anything optional

     - Parameters:
       - aAny: Any optional object.

     - Returns: String "nil" if argument is `nil`, otherwise the argument converted to String.
     */
    public static func unwrapping(_ aAny: Any?) -> String {
        guard let any = aAny else {
            return "nil"
        }
        return "\(any)"
    }
}


/**
 * :nodoc:
 * A regrettable implementation artefact
 */
extension Substring: Chompable {}
