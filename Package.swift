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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "update-strings",
            dependencies: [
                "UpdateStringsModels",
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
