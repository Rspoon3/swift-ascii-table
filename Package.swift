// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ascii-table",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ASCIITable",
            targets: ["ASCIITable"]
        ),
        .executable(
            name: "ANSIColorExample",
            targets: ["ANSIColorExample"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main")
    ],
    targets: [
        .target(
            name: "ASCIITable",
            path: "Sources/swift-ascii-table"
        ),
        .executableTarget(
            name: "ANSIColorExample",
            dependencies: ["ASCIITable"],
            path: "Examples",
            sources: ["ANSIColorExample.swift"]
        ),
        .testTarget(
            name: "ASCIITableTests",
            dependencies: [
                "ASCIITable",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/swift-ascii-tableTests"
        ),
    ]
)
