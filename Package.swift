// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SimplifySwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SimplifySwift",
            targets: ["SimplifySwift"])
    ],
    targets: [
        .target(
            name: "SimplifySwift",
            dependencies: []),
        .testTarget(
            name: "SimplifySwiftTests",
            dependencies: ["SimplifySwift"])
    ],
    swiftLanguageVersions: [.v5]
)
