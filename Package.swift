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
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "YNImageAsync",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "YNImageAsyncTests",
            dependencies: ["YNImageAsync"]
        ),
    ]
)
