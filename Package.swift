// swift-tools-version: 5.7
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
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", revision: "850bb6e86b426ec025630510d19fcb9d19a3d84d")
//        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", branch: "feature/new_visual_paywalls")
//        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", "2.6.1" ..< "2.7.0")
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
