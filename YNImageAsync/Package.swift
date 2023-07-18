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
    targets: [
        .target(
            name: "YNImageAsync"),
        .testTarget(
            name: "YNImageAsyncTests",
            dependencies: ["YNImageAsync"]
        ),
    ]
)
