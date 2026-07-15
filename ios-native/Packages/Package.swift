// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "DomainModule", targets: ["DomainModule"]),
        .library(name: "DataModule", targets: ["DataModule"]),
    ],
    targets: [
        .target(
            name: "DomainModule",
            path: "Sources/DomainModule"
        ),
        .target(
            name: "DataModule",
            dependencies: ["DomainModule"],
            path: "Sources/DataModule"
        ),
    ],
    swiftLanguageModes: [.v6]
)
