// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Device",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Device", targets: ["Device"]),
        .library(name: "DeviceImplementation", targets: ["DeviceImplementation"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Device"),
        .target(name: "DeviceImplementation",)
    ]
)
