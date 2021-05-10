// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Iwstb",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(name: "Iwstb", targets: ["Iwstb"])
    ],
    targets: [
        .target(name: "Iwstb", path: "Sources"),
        .testTarget(
            name: "IwstbTests", 
            dependencies: ["Iwstb"], 
            path: "Tests",
            resources: [
                .copy("LineReaderTestData")
            ]
        )
    ]
)
