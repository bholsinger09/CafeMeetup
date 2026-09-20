// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShareACoffeeStudy",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ShareACoffeeStudy", targets: ["ShareACoffeeStudy"])
    ],
    dependencies: [
        .package(path: "../ShareACoffeeCore")
    ],
    targets: [
        .target(
            name: "ShareACoffeeStudy",
            dependencies: [
                .product(name: "ShareACoffeeCore", package: "ShareACoffeeCore")
            ],
            path: "Sources/ShareACoffeeStudy"
        ),
        .testTarget(
            name: "ShareACoffeeStudyTests",
            dependencies: ["ShareACoffeeStudy"],
            path: "Tests/ShareACoffeeStudyTests"
        )
    ]
)
