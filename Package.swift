// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlatBuffers",
    products: [
        .library(
            name: "FlatBuffers",
            targets: ["FlatBuffers"]),
    ],
    targets: [
        .target(
            name: "FlatBuffers",
            dependencies: []),
        .testTarget(
            name: "FlatBuffersTests",
            dependencies: ["FlatBuffers"]),
    ]
)
