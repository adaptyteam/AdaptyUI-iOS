// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AdaptyUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "AdaptyUI",
            targets: ["AdaptyUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", "2.11.0" ..< "2.12.0")
    ],
    targets: [
        .target(
            name: "AdaptyUI",
            dependencies: [
                .product(name: "Adapty", package: "AdaptySDK-iOS")
            ],
            path: "Sources"),
        .testTarget(
            name: "AdaptyUITests",
            dependencies: ["AdaptyUI"]),
    ]
)
