// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
    ], 
    dependencies: [
        .package(path: "../Models"),
        .package(url: "https://github.com/raskavil/SupportPackage", branch: "main")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                "Models",
                "SupportPackage"
            ]
        )
    ]
)
