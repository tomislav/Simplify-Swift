// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Simplify-Swift",
    products: [
        .library(
            name: "Simplify-Swift",
            targets: ["Simplify-Swift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Simplify-Swift",
            dependencies: [],
            exclude: ["Example"])
    ]
)
