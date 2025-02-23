// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-ioc",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftIoC",
            targets: ["SwiftIoC"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftIoC",
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftIoCTests",
            dependencies: ["SwiftIoC"],
            path: "Tests"
        ),
    ]
)
