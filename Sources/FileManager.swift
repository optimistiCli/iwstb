import Foundation

public extension FileManager {
    /**
     Creates an `URL` for a file or dir avoiding collisions with existing files by adding a consecutive number
     to the file name.

     - Parameters:
       - aFolder: An `URL` of a folder where the new file is to be created. Can point to an existing
                  folder or to a path that doesn't exist.
       - aNameBase: A new file name without extension. Should not be empty and should only consist of
                    valid characters.
       - aExt: New file extension or nill if none. Should not be empty and should only consist of valid
               characters.
       - aNameFormat: A `String(format: …)` format for names with added number. Defaults to
                      `"%@ %d"`

     - Returns: An `URL` of a file or folder that can be safely created without a collision with an existing
                filw system object.
     */
    func cookUrlAddingNumberIfDuplicate(
            in aFolder: URL,
            nameSansExt aNameBase: String,
            ext aExt: String? = nil,
            nameFormat aNameFormat: String = "%@ %d"
            ) throws -> URL {
        guard aFolder.isFileURL else {
            throw Iwstb.Error(because: "Not a file URL >\(aFolder)<")
        }
        // If isFileURL && isDir == nil => the folder doesn't exist yet
        guard aFolder.isDir ?? true else {
            throw Iwstb.Error(because: "Not a folder >\(aFolder)<")
        }
        guard !aNameBase.isEmpty else {
            throw Iwstb.Error(because: "Name is empty")
        }
        guard aNameBase.firstIndex(of: "/") == nil else {
            throw Iwstb.Error(because:
                    "Name contains illegal character >\(aNameBase)<")
        }
        var candidate: URL
        var attempt: Int = 1
        var cookNextCandidate: () -> ()
        if let ext = aExt {
            guard !ext.isEmpty else {
                throw Iwstb.Error(because: "Extension is empty")
            }
            guard ext.firstIndex(of: "/") == nil else {
                throw Iwstb.Error(because:
                        "Extension contains illegal character >\(aNameBase)<")
            }
            candidate = aFolder.appendingPathComponent(aNameBase + "." + ext)
            let nameWithExtFormat = aNameFormat + ".%@"
            cookNextCandidate = {
                candidate = aFolder.appendingPathComponent(String(
                        format: nameWithExtFormat,
                        aNameBase,
                        attempt,
                        ext
                        ))
            }
        } else {
            candidate = aFolder.appendingPathComponent(aNameBase)
            cookNextCandidate = {
                candidate = aFolder.appendingPathComponent(String(
                        format: aNameFormat,
                        aNameBase,
                        attempt
                        ))
            }
        }
        while fileExists(atPath: candidate.path) {
            cookNextCandidate()
            attempt += 1
        }
        return candidate
    }
}

