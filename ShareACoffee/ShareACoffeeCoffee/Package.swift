// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeCoffee",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeCoffee", targets: ["ShareACoffeeCoffee"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore"),
        .package(path: "../ShareACoffeeStudy")
    ],
    targets: [
        .target(
            name: "ShareACoffeeCoffee",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore"),
                .product(name: "ShareACoffeeStudy", package: "ShareACoffeeStudy")
            ],
            path: "Sources/ShareACoffeeCoffee"
        ),
        .testTarget(
            name: "ShareACoffeeCoffeeTests",
            dependencies: ["ShareACoffeeCoffee"],
            path: "Tests/ShareACoffeeCoffeeTests"
        )
    ]
)
