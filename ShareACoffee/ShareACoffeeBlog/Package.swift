// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeBlog",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeBlog", targets: ["ShareACoffeeBlog"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore"),
        .package(path: "../ShareACoffeeAuth")
    ],
    targets: [
        .target(
            name: "ShareACoffeeBlog",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore"),
                .product(name: "ShareACoffeeAuth", package: "ShareACoffeeAuth")
            ],
            path: "Sources/ShareACoffeeBlog"
        ),
        .testTarget(
            name: "ShareACoffeeBlogTests",
            dependencies: ["ShareACoffeeBlog"],
            path: "Tests/ShareACoffeeBlogTests"
        )
    ]
)
