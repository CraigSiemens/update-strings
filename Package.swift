// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "update-strings",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "update-strings", targets: ["update-strings"]),
        .library(name: "UpdateStringsModels", targets: ["UpdateStringsModels"])
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "update-strings",
            dependencies: [
                "UpdateStringsModels",
                "SwiftShell",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        
        .target(name: "UpdateStringsModels"),
        .testTarget(
            name: "UpdateStringsModelsTests",
            dependencies: ["UpdateStringsModels"],
            resources: [.copy("Fixtures")]
        )
    ]
)
