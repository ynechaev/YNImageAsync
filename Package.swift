// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YNImageAsync",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "YNImageAsync",
            targets: ["YNImageAsync"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YNImageAsync",
            dependencies: []
        ),
        .testTarget(
            name: "YNImageAsyncTests",
            dependencies: ["YNImageAsync"],
            path: "Tests"
        ),
    ]
)
