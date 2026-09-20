// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeCore", targets: ["ShareACoffeeCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ShareACoffeeCore",
            dependencies: [],
            path: "Sources/ShareACoffeeCore"
        ),
        .testTarget(
            name: "ShareACoffeeCoreTests",
            dependencies: ["ShareACoffeeCore"],
            path: "Tests/ShareACoffeeCoreTests"
        )
    ]
)
