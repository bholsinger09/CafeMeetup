// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeProfile",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeProfile", targets: ["ShareACoffeeProfile"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore"),
        .package(path: "../ShareACoffeeStudy"),
        .package(path: "../ShareACoffeeCoffee")
    ],
    targets: [
        .target(
            name: "ShareACoffeeProfile",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore"),
                .product(name: "ShareACoffeeStudy", package: "ShareACoffeeStudy"),
                .product(name: "ShareACoffeeCoffee", package: "ShareACoffeeCoffee")
            ],
            path: "Sources/ShareACoffeeProfile"
        ),
        .testTarget(
            name: "ShareACoffeeProfileTests",
            dependencies: ["ShareACoffeeProfile"],
            path: "Tests/ShareACoffeeProfileTests"
        )
    ]
)
