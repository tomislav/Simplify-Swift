// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SimplifySwift",
    products: [
        .library(
            name: "SimplifySwift",
            targets: ["SimplifySwift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SimplifySwift",
            dependencies: [],
            exclude: ["Example"])
    ]
)
