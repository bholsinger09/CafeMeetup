// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeAuth",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeAuth", targets: ["ShareACoffeeAuth"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore"),
        .package(path: "../ShareACoffeeCoffee")
    ],
    targets: [
        .target(
            name: "ShareACoffeeAuth",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore"),
                .product(name: "ShareACoffeeCoffee", package: "ShareACoffeeCoffee")
            ],
            path: "Sources/ShareACoffeeAuth"
        ),
        .testTarget(
            name: "ShareACoffeeAuthTests",
            dependencies: ["ShareACoffeeAuth"],
            path: "Tests/ShareACoffeeAuthTests"
        )
    ]
)
