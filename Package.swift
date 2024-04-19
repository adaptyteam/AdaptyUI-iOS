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
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", revision: "73fd323f1240f3fa8f163c9bb8944ff2bc747f5b")
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
