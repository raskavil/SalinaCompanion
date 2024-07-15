// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Device",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Device", targets: ["Device"]),
    ],
    dependencies: [
        .package(url: "https://github.com/raskavil/SupportPackage", branch: "main")
    ],
    targets: [
        .target(
            name: "Device",
            dependencies: [
                "SupportPackage"
            ]
        )
    ]
)
