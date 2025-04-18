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
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftIoC",
            dependencies: [
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftIoCTests",
            dependencies: ["SwiftIoC"],
            path: "Tests"
        ),
    ]
)
