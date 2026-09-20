// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeSocial",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeSocial", targets: ["ShareACoffeeSocial"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore")
    ],
    targets: [
        .target(
            name: "ShareACoffeeSocial",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore")
            ],
            path: "Sources/ShareACoffeeSocial"
        ),
        .testTarget(
            name: "ShareACoffeeSocialTests",
            dependencies: ["ShareACoffeeSocial"],
            path: "Tests/ShareACoffeeSocialTests"
        )
    ]
)
