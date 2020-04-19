// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "update-strings",
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "4.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "update-strings",
            dependencies: ["SwiftShell", "Commander"]),
    ]
)
