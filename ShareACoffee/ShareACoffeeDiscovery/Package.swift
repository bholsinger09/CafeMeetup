// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeDiscovery",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeDiscovery", targets: ["ShareACoffeeDiscovery"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore"),
        .package(path: "../ShareACoffeeSocial")
    ],
    targets: [
        .target(
            name: "ShareACoffeeDiscovery",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore"),
                .product(name: "ShareACoffeeSocial", package: "ShareACoffeeSocial")
            ],
            path: "Sources/ShareACoffeeDiscovery"
        ),
        .testTarget(
            name: "ShareACoffeeDiscoveryTests",
            dependencies: ["ShareACoffeeDiscovery"],
            path: "Tests/ShareACoffeeDiscoveryTests"
        )
    ]
)
