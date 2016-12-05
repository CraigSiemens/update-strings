import PackageDescription

let package = Package(
    name: "spool",
    dependencies: [
        .Package(url: "https://github.com/oarrabi/Runner.git", majorVersion: 0),
        .Package(url: "git@github.com:kylef/Commander.git", majorVersion: 0),
    ]
)
