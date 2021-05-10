import Foundation

/**
 # Ish West Swift Toolbox

 A random collection of handy tools.
 */
public class Iwstb {
    let version = "0.1.1"


    // MARK: Program

    /**
     Name of the actual executable file.
     */
    public static let prog: String = NSString(string:
            ProcessInfo.processInfo.arguments[0]
            ).lastPathComponent

    /**
     File URL of the actual executable.
     */
    public static let progUrl: URL = URL(fileURLWithPath:
            ProcessInfo.processInfo.arguments[0]
            )


    // MARK: Usage

    /**
     This token is replaced with the actual executable file name in the usage template.
     */
    public static let USAGE_PROG_TOKEN: String = "$PROG"

    /**
     Marks the end of the short usage text in the usage template.
     */
    public static let USAGE_LONG_SEPARATOR: Character = "\u{2702}"

    private static var _usage: String?
    private static var _usageLong: String?
    private static let _usagePlaceholder = """
            Usage:
              \(USAGE_PROG_TOKEN)

            You shoud look for explanation elswhere since this is a placehilder.\(USAGE_LONG_SEPARATOR)

            Because this is just a default placeholder.
            """

    /**
     Provide usage text(s) used command line help.

     Intended use, assuming the default prog token and long help separator:
     ~~~
     Iwstb.updateUsage(
         """
         Usage:
           $PROG [-h] [-c] [-q] <data file>

           A line or two about the program.\u{2702}

         Options:
           h - Show help and exit
           c - A common option\u{2702}
           q - Not so common option

         Examples:
           Process a data file
           $ $PROG data.file

           Quietly process a data file
           $ $PROG -q data.file
         """
     )
     …
     if (some.condition) {
         print(Iwstb.usage)
     } else {
         print(Iwstb.usageLong)
     }
     ~~~

     Then short help output will be like this:
     ~~~
     $ myprog -h
     Usage:
       myprog [-h] [-c] [-q] <data file>

       A line or two about the program.

     Options:
       h - Show help and exit
       c - A common option
     ~~~


     And the long help output like this:
     ~~~
     $ myprog --long-help
     Usage:
       myprog [-h] [-c] [-q] <data file>

       A line or two about the program.

     Options:
       h - Show help and exit
       c - A common option
       q - Not so common option

     Examples:
       Process a data file
       $ myprog data.file

       Quietly process a data file
       $ myprog -q data.file
     ~~~

     - Parameters:
       - aTemplate: Usage template text.
       - aToken: Prog token string, will be replaced with actual executable
                 file name. If ommited default value USAGE_PROG_TOKEN is used.
       - aSeparator: Long help separator charcter. If ommited default value
                     USAGE_LONG_SEPARATOR is used.
     */
    public static func updateUsage(
            with aTemplate: String,
            progName aToken: String = USAGE_PROG_TOKEN,
            cutLongAt aSeparator: Character = USAGE_LONG_SEPARATOR
            ) {
        let buffer = aTemplate.replacingOccurrences(of: aToken, with: prog)
        let parts = buffer.split(
                separator: aSeparator,
                maxSplits: 1,
                omittingEmptySubsequences: false
                )
        if parts.count == 2 {
            _usage = String(parts[0])
            _usageLong = parts.joined()
        } else {
            _usage = buffer
            _usageLong = buffer
        }
    }

    /**
     Short usage text. Unless a usage template was previously provided via a
     call to `updateUsage` an ugly placeholder is used.
     */
    public static var usage: String {
        guard let u = _usage else {
            updateUsage(with: _usagePlaceholder)
            return _usage!
        }
        return u
    }

    /**
     Long usage text. Unless a usage template was previously provided via a
     call to `updateUsage` an ugly placeholder is used.
     */
    public static var usageLong: String {
        guard let u = _usageLong else {
            updateUsage(with: _usagePlaceholder)
            return _usageLong!
        }
        return u
    }


    // MARK: Error reporting, warnings, logging

    /**
     Prints something to STDERR.
     */
    public static func log(_ smth: Any) {
        fputs("\(smth)\n", stderr)
    }

    private static let _errorMessagePlaceholder
            = "Something went terribly wrong"
    private static let _warninMessagePlaceholder
            = "Probably something went wrong"

    /**
     Prints an error message followed by short usage text.

     Intended use:
     ~~~
     // main.swift

     fileprivate func main() -> Int32 {
         Iwstb.updateUsage(
            """
            …
            """
         …
         if something.isWrong {
             return Iwstb.brag("A specific problem description")
         }
         …
         do {
            try doSomethingRisky()
         } catch {
             return Iwstb.brag(error, exitCode: 127)
         }
     }

     exit(main())
     ~~~

    This produces output like this:
     ~~~
     $ myprog bad.file
     Error:
       A specific problem description

     Usage:
       myprog [-h] [-c] [-q] <data file>

       A line or two about the program.

     Options:
       h - Show help and exit
       c - A common option
     ~~~

     - Parameters:
       - aReason: An error message. If the passed value conforms to IwstbError
                  protocol then it's `reason` property is printed. If ommited
                  a generic placeholder is used.
       - exitCode: Program exit code to be passed to `exit(_:)` call.
                   If ommited default value `1` is used.

     - Returns: An exit code to be passed to `exit(_:)` call.
     */
    public static func brag(
            _ aReason: Any? = nil,
            exitCode aExitCode: Int32 = 1
            ) -> Int32 {
        let msg: String = {
            guard let reason = aReason else {
                return _errorMessagePlaceholder
            }
            return (reason as? IwstbError)?.reason ?? "\(reason)"
        }()
        log("Error:\n  \(msg)\n\n\(usage)")
        return aExitCode
    }

    /**
     Prints a warning to STDERR.

     - Parameters:
       - aMessage: A warning message. If ommited a generic placeholder is used.
     */
    public static func moan(_ aMessage: String? = nil) {
        log("Warning: \(aMessage ?? _warninMessagePlaceholder)")
    }


    // MARK: Running other apps

    /**
     A convenience method for running another application and waiting for it.

     - Parameters:
       - aExecutableFileUrl: A file URL of an executable.
       - aArguments: An array of strings containing command line arguments to
                     be passed to the executable.

     - Returns: Exit code of run executable.

     - Throws: Lets thru whatever `Process.run` throws.
     */
    public static func run(
            _ aExecutableFileUrl: URL,
            arguments aArguments: [String]? = nil
            ) throws -> Int32 {
        let p = Process()
        p.executableURL = aExecutableFileUrl
        p.arguments = aArguments
        try p.run()
        p.waitUntilExit()
        return p.terminationStatus
    }


    // MARK: Getopter

    /**
     Produces a new instance of `Getopter`: a convinience wrapper for the C getopt.

     Intended use pattern:
     ~~~
     let getopter = Iwstb.cookGetopter(":ho:")

     for result in getopter {
         if result.option == "h" {
             showHelpAndExit = true
         } else if result.option == "o" {
             outputPath = result.argument
         }
     }

     if let args = getopter.remaining {
        processArgs(args)
     }
     ~~~

     - Parameters:
       - aOptString: A string of getopt options. Please check out the optstring description in getopt
                     C call man page. A colon is always prepended to the passed string. If ommited
                     a single colon is passed which allows to read any argumentless options.

     - Returns: A new Getopter instance.
     */
    public static func cookGetopter(_ aOptString: String = ":") -> Getopter {
        return Getopter(aOptString)
    }


    // MARK: LineReader

    /**
     Produces a instance of `LineReader`: a convenience itterator for reading 
     text files line-by-line.

     Intended use pattern:
     ~~~
     let lineReader = try Iwstb.cookLineReader(fileUrl)
     …
     for line in lineReader {
         process(line)
     }
     ~~~

     - Parameters:
       - aUrl: A file URL of a text file. Currently only UTF-8 encoded files 
               with Unix line endings are supported.
       - aChomp: Controlls the leading and trailing whitespaces treatment. 
                 Available options are to chomp (trim) `.trailing`, `.leading`, 
                 `.both` or `.neither`. If ommited the trailing whitespaces are
                 chomped. 

     - Returns: A new `LineReader` instance.

     - Throws: `LineReader.Error`
     */
    public static func cookLineReader(
            _ aUrl: URL,
            chomp aChomp: LineReader.Chomp = .trailing
            ) throws -> LineReader {
        return try LineReader(aUrl, chomp: aChomp)
    }


    // MARK: Regexer

    /**
     Produces a instance of `Regexer`: a convenience wrapper for the  `NSRegularExpression`.


     Intended use pattern:
     ```
     guard let re = Iwstb.cookRegexer(#"(?<=before\s)(?:(one)|(two)|(three))(?=\safter)"#) else {
        throw Error(because: "Bad regex pattern")
     }
     if let matches = re.search(someString) {
        if !matches[1].isEmpty {
            print("It's a one")
        } else {
            print("It isn't a one")
        }
     } else {
        print("None found")
     }
     ```

     - Parameters:
       - aUrl: A regex pattern string.
       - aOptions: An array of `NSRegularExpression.Options`.

     - Returns: A new `Regexer` instance or `nil` if an error prevented it's creation.
     */
    public static func cookRegexer(
            _ aPattern: String,
            options aOptions: NSRegularExpression.Options = []
            ) -> Regexer? {
        do {
            return try Regexer(aPattern, options: aOptions)
        } catch {
            return nil
        }
    }
}
