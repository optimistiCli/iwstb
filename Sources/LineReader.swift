import Foundation

/**
 Convenience itterator for reading text files line-by-line.

 Please see `cookLineReader` in `Iwstb` for more docs.
 */
public class LineReader: Sequence, IteratorProtocol {
    /**
     An umbrella type for all `LineReader` errors
     */
    class Error: Iwstb.Error {}

    /**
     File does not exist
     */
    class DoesntExistError: LineReader.Error {
        internal init(_ aPathStr: String) {
            super.init(because: "The LineReader file “\(aPathStr)” doesn't seem to exist.")
        }
    }

    /**
     Path points at a directory, instead of a file
     */
    class IsDirectoryError: LineReader.Error {
        internal init(_ aPathStr: String) {
            super.init(because: "A directory is passed in place of the main LineReader file “\(aPathStr)”.")
        }
    }

    /**
     Cannot read file
     */
    class NotReadableError: LineReader.Error {
        internal init(_ aPathStr: String) {
            super.init(because: "Can't read the LineReader file “\(aPathStr)”.")
        }
    }

    /**
     Cannot open file for reading
     */
    class OpenFailedError: LineReader.Error {
        internal init(_ aPathStr: String) {
            super.init(because: "Can't open the main JXA file “\(aPathStr)” for reading.")
        }
    }

    /**
     Instructs `LineReader` on which side should whitespaces be trimmed.
     */
    public enum Chomp {
        /**
         Trim trailing whitespaces
         */
        case trailing

        /**
         Trim leading whitespaces
         */
        case leading

        /**
         Trim  both leading and trailing whitespaces
         */
        case both

        /**
         Don't trim whitespaces
         */
        case neither
    }

    private let _url: URL
    private let _toString: (UnsafeMutablePointer<CChar>) -> Substring?
    private var _exhausted: Bool
    private let _filePointer: UnsafeMutablePointer<FILE>

    internal init(_ aUrl: URL, chomp aChomp: Chomp) throws {
        _url = aUrl
        let absPath = aUrl.path
        let fm = FileManager.default

        var isDir : ObjCBool = false
        guard fm.fileExists(atPath: absPath, isDirectory: &isDir) else {
            throw DoesntExistError(absPath)
        }

        if isDir.boolValue {
            throw IsDirectoryError(absPath)
        }

        guard fm.isReadableFile(atPath: absPath) else {
            throw NotReadableError(absPath)
        }

        guard let filePointer = fopen(absPath, "r") else {
            throw OpenFailedError(absPath)
        }

        switch aChomp {
            case .trailing:
                _toString = { return String.init(cString: $0).chompedTrailing ?? "" }
            case .leading:
                _toString = { return String.init(cString: $0).chompedLeading ?? "" }
            case .both:
                _toString = { return String.init(cString: $0).chompedBoth ?? "" }
            case .neither:
                _toString = { return String.init(cString: $0)[...] }
        }
        _filePointer = filePointer
        _exhausted = false
    }

    /**
     The `URL` of the file that this instance of `LineReader` is reading.
     */
    public var url: URL {
        return _url
    }

    public func next() -> Substring? {
        if (_exhausted) {
            return nil
        } else {
            var lineBuffer: UnsafeMutablePointer<CChar>? = nil
            var lineCap: Int = 0
            if getline(&lineBuffer, &lineCap, _filePointer) > 0 {
                return _toString(lineBuffer!)
            } else {
                _exhausted = true
                fclose(_filePointer)
                return nil
            }
        }
    }
}
