import PackageDescription

let package = Package(
    name: "HTTPCore",
    dependencies: [
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 14),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 14),
        .Package(url: "https://github.com/slimane-swift/Core.git", majorVersion: 0, minor: 1),
    ]
)
