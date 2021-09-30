import Foundation

public extension URL {
    /**
     Creates a file URL of a (possibly inexistant) object referenced by this URL relative to a (possibly inexistant)
     base URL. An inexistant base object is assumed to be a file rather then a directory unless specified
     otherwise by the optional `assumeMissingBaseIsDir` param.

     Intended use:
     ~~~
     let htmlUrl = URL(fileURLWithPath: "/some/path/index.html")
     let imageUrl = URL(fileURLWithPath: "/yet/another/path/picture.jpg")
     let imgTag = "<img src=\"\(imageUrl.cookUrlRelative(to: htmlUrl)!.relativeString)\" />"
     ~~~

     - Parameters:
       - aBaseUrl: A file URL to be used as a base for the relative URL being cooked here.
       - assumeMissingBaseIsDir: If true forces the `to` URL to be considered  a reference to a
            directory in case it doesn't (yet) exist in the FS. Otherwise inexistant base URL is cosidered
            a file.

     - Returns: A new file URL object or nil if it couldn't been created.
     */
    func cookUrlRelative(
            to aBaseUrl: URL,
            assumeMissingBaseIsDir aAssumeDir: Bool? = nil
            ) -> URL? {
        guard self.isFileURL && aBaseUrl.isFileURL else {
            return nil
        }
        let isDir = aBaseUrl.isDir
                ?? aAssumeDir
                ?? false // Treat unknown inexistant path as if it was a file
        guard let baseUrl = isDir ? aBaseUrl : aBaseUrl.cookParentUrl() else {
            return nil
        }
        guard let targetComps = normalizedPathComponents,
                let baseComps = baseUrl.normalizedPathComponents
                else {
            return nil
        }
        var i: Int = 1
        let targetNum = targetComps.count
        let baseNum = baseComps.count
        while i < targetNum && i < baseNum && targetComps[i] == baseComps[i] {
            i += 1
        }
        let cdups = Array.init(repeating: "..", count: baseComps.count - i)
        let toTarget = targetComps[i..<targetComps.count]
        return URL(
                fileURLWithPath: (cdups + toTarget).joined(separator: "/"),
                relativeTo: aBaseUrl
                )
    }

    /**
     Similar to `pathComponents` but resolves all single and double dots in the path.
     */
    var normalizedPathComponents: [String]? {
        guard isFileURL else {
            return nil
        }
        let components = pathComponents
        guard components.count > 1 else {
            return ["/"]
        }
        var buffer: [String] = ["/"]
        for comp in components[1...] {
            if comp == "." {
                continue
            }
            if comp == ".." {
                if buffer.count > 1 {
                    _ = buffer.popLast()
                }
                continue
            }
            buffer.append(comp)
        }
        return buffer
    }

    /**
     Cretes new URL object referencing the same path in the FS but resolving all dots and double dots in the
     path.

     - Returns: A new file URL object or nil if it couldn't been created.
     */
    func normalizingPathComponents() -> URL? {
        guard let components = normalizedPathComponents else {
            return nil
        }
        return NSURL.fileURL(withPathComponents: components)
    }

    /**
     Similar to `deletingLastPathComponent()` but respects the fact that FS root's parent is the FS
     root itself.

     - Returns: A new file URL object or nil if it couldn't been created.
     */
    func cookParentUrl() -> URL? {
        guard isFileURL else {
            return nil
        }
        return normalizedPathComponents?.count == 1
            ? URL(fileURLWithPath: "/")
            : deletingLastPathComponent()
    }

    /**
     True if URL references an FS directory or a symlink to a directory. False if any other file system object.
     Nil otherwise: for example if file doesn't exist, of if it is not a file URL etc.
     */
    var isDir: Bool? {
        guard isFileURL else {
            return nil
        }
        guard let realUrl = realyResolvingSymlinksInPath() else {
            return nil
        }
        guard let res = try? realUrl.resourceValues(forKeys: [.isDirectoryKey]),
                let isDir = res.isDirectory
                else {
            return nil
        }
        return isDir
    }

    /**
     Similar to `resolvingSymlinksInPath` but also resolves `/etc` to `/private/etc`

     - Returns: A new file URL object or nil if it couldn't been created.
     */
    func realyResolvingSymlinksInPath() -> URL? {
        guard isFileURL else {
            return nil
        }
        let fm = FileManager.default
        func recu(_ aU: URL, _ aA: inout [String]) -> URL? {
            guard let res = try? aU.resourceValues(forKeys: [.isSymbolicLinkKey]),
                    let isSymLink = res.isSymbolicLink,
                    let u = isSymLink
                    ? try? URL(
                            fileURLWithPath: fm.destinationOfSymbolicLink(atPath: aU.path),
                            relativeTo: aU.deletingLastPathComponent()
                            )
                    : aU
                    else {
                return nil
            }
            let comp = u.lastPathComponent
            aA.append(comp)
            if comp == "/" {
                return NSURL.fileURL(withPathComponents: aA.reversed())
            } else {
                let oo1 = NSString(string: u.path).deletingLastPathComponent
                let oo2 = URL(fileURLWithPath: oo1)
                return recu(oo2, &aA)
            }
        }
        var a = [String]()
        return recu(self, &a)
    }

    /**
     In the spirit of `pathExtension` returns the name of file URL points to without extension.

     - Returns: A new `String` with file name.
     */
    var pathName: String {
        let extCount = pathExtension.count
        return extCount > 0
            ? String(lastPathComponent.dropLast(extCount + 1))
            : lastPathComponent
    }
}
