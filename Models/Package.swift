// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v16)],
    products: [.library(name: "Models", targets: ["Models"])],
    dependencies: [.package(url: "https://github.com/raskavil/SupportPackage", branch: "main")],
    targets: [.target(name: "Models", dependencies: [.product(name: "SupportPackageViews", package: "SupportPackage")])]
)
