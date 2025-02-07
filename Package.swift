// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "stats",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "stats",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "Rainbow"),
            ]),
        .testTarget(
            name: "statsTests",
            dependencies: ["stats"]),
    ]
)
