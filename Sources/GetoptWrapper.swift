import Foundation

/**
 Convinience wrapper for the C getopt

 Please see `cookGetopter` in `Iwstb` for more docs.
 */
public class Getopter: Sequence, IteratorProtocol {
    // TODO: Switch to getopt_long for long options support

    /**
     Data structure describing a command line option detected by getopt.
     */
    public struct Result {
        /**
         The character that denotes detected option.

         For `-h` command line option this parameter will be `"h"`
         */
        let option: Character

        /**
         Option argument

         Only available if the option was declared with colon in the optstring. Otherwise it's `nil`.
         */
        let argument: String?

        /**
         Indicates if this option was missing from the optstring.

         Please note that if this parameter is `true` then the `argument` parameter is guarantied
         to be `nil`.
         */
        let missing: Bool
    }

    private let _argc: Int32
    private let _argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>
    private let _arguments: [String]

    private let _optString: String

    private var _exhausted: Bool
    private var _optind: Int

    internal init(_ aOptString: String) {
        _argc = CommandLine.argc
        _argv = CommandLine.unsafeArgv
        _arguments = CommandLine.arguments
        _optString = aOptString.starts(with: ":")
            ? aOptString
            : ":\(aOptString)"
        _exhausted = false
        _optind = 0
    }

    public func next() -> Result? {
        if _exhausted {
            return nil
        }
        let optRaw = getopt(_argc, _argv, _optString)
        _optind = Int(optind)
        if optRaw == -1 {
            _exhausted = true
            return nil
        }
        let option = Character(UnicodeScalar(CUnsignedChar(optRaw)))
        if option == "?" {
            return Result(
                    option: Character(UnicodeScalar(UInt8(optopt))),
                    argument: nil,
                    missing: true
                    )
        } else {
            return optarg == nil
                ? Result(
                        option: option,
                        argument: nil,
                        missing: false
                        )
                : Result(
                        option: option,
                        argument: String(cString: optarg),
                        missing: false
                        )
        }
    }

    /**
     Remaining command line arguments

     Returns all the command line arguments positioned after detected command line options. Or `nil`
     if none remain.
     */
    public var remaining: [String]? {
        let rem = _arguments.dropFirst(_optind)
        if rem.count > 0 {
            return Array(rem)
        } else {
            return nil
        }
    }
}
