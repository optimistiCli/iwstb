import XCTest
import Foundation
@testable import Iwstb

class UrlTests: XCTestCase {
    func testIsDir() {
        XCTAssertNil(URL(string: "http://www.altavista.com/")!.isDir)
        XCTAssertNil(URL(fileURLWithPath: "/HIMEM.SYS").isDir)
        XCTAssertTrue(URL(fileURLWithPath: "/bin").isDir!)
        XCTAssertTrue(URL(fileURLWithPath: "/etc").isDir!)
        XCTAssertFalse(URL(fileURLWithPath: "/etc/hosts").isDir!)
    }

    func testCookParentUrl() {
        XCTAssertNil(URL(string: "http://www.altavista.com/")!.cookParentUrl())
        XCTAssertEqual(URL(fileURLWithPath: "/bin/sh").cookParentUrl()!.path, "/bin")
        XCTAssertEqual(URL(fileURLWithPath: "/etc/hosts").cookParentUrl()!.path, "/etc")
        XCTAssertEqual(URL(fileURLWithPath: "/").cookParentUrl()!.path, "/")
        XCTAssertEqual(URL(fileURLWithPath: "/.././../").cookParentUrl()!.path, "/")
        // TODO: Add test for ln -s / /some/dir/link_to_fs_root
    }

    func testNormalizingPathComponents() {
        XCTAssertNil(URL(string:
                "http://www.altavista.com/")!.normalizingPathComponents())
        XCTAssertEqual(URL(fileURLWithPath:
                "/etc/defaults/../hosts").normalizingPathComponents()!.path,
                "/etc/hosts"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/etc/./hosts").normalizingPathComponents()!.path,
                "/etc/hosts"
                )
    }

    func testCookUrlRelative() {
        XCTAssertNil(URL(string:
                "http://www.altavista.com/")!.cookUrlRelative(to:
                URL(fileURLWithPath: "/")
                ))
        XCTAssertNil(URL(fileURLWithPath:
                "/").cookUrlRelative(to:
                URL(string: "http://www.altavista.com/")!
                ))

        XCTAssertEqual(URL(fileURLWithPath:
                "/tmp/somefile").cookUrlRelative(to:
                URL(fileURLWithPath: "/bin/sh"))?.relativePath,
                "../tmp/somefile"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/tmp/somefile").cookUrlRelative(to:
                URL(fileURLWithPath: "/bin/"))?.relativePath,
                "../tmp/somefile"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/tmp/somefile").cookUrlRelative(to:
                URL(fileURLWithPath: "/bin/somefile"))?.relativePath,
                "../tmp/somefile"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/tmp/somefile").cookUrlRelative(to:
                URL(fileURLWithPath: "/bin/somefile"),
                assumeMissingBaseIsDir: false)?.relativePath,
                "../tmp/somefile"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/tmp/somefile").cookUrlRelative(to:
                URL(fileURLWithPath: "/bin/somedir"),
                assumeMissingBaseIsDir: true)?.relativePath,
                "../../tmp/somefile"
                )

//        XCTAssertEqual(URL(fileURLWithPath:
//                "/tmp/somefile").cookUrlRelative(to:
//                URL(fileURLWithPath: "/etc/hosts"))?.relativePath,
//                "../tmp/somefile"
//                )
//        XCTAssertEqual(URL(fileURLWithPath:
//                "/tmp/somefile").cookUrlRelative(to:
//                URL(fileURLWithPath: "/etc/"))?.relativePath,
//                "../tmp/somefile"
//                )
//        XCTAssertEqual(URL(fileURLWithPath:
//                "/tmp/somefile").cookUrlRelative(to:
//                URL(fileURLWithPath: "/etc/somefile"))?.relativePath,
//                "../tmp/somefile"
//                )
//        XCTAssertEqual(URL(fileURLWithPath:
//                "/tmp/somefile").cookUrlRelative(to:
//                URL(fileURLWithPath: "/etc/somefile"),
//                assumeMissingBaseIsDir: false)?.relativePath,
//                "../tmp/somefile"
//                )
//        XCTAssertEqual(URL(fileURLWithPath:
//                "/tmp/somefile").cookUrlRelative(to:
//                URL(fileURLWithPath: "/etc/somedir"),
//                assumeMissingBaseIsDir: true)?.relativePath,
//                "../../tmp/somedir"
//                )
    }

    func testRealyResolvingSymlinksInPath() {
        XCTAssertNil(URL(string:
                "http://www.altavista.com/")!.realyResolvingSymlinksInPath())
        XCTAssertEqual(URL(fileURLWithPath:
                "/etc").realyResolvingSymlinksInPath()!.path,
                "/private/etc"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/etc/resolv.conf").realyResolvingSymlinksInPath()!.path,
                "/private/var/run/resolv.conf"
                )
        XCTAssertEqual(URL(fileURLWithPath:
                "/etc/localtime").realyResolvingSymlinksInPath()!.path.prefix(25),
                "/private/var/db/timezone/"
                )
    }
}
