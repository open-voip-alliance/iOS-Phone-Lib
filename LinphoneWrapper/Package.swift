// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LinphoneWrapper",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LinphoneWrapper",
            targets: ["LinphoneWrapper"]
        )
    ],
    dependencies: [
        .package(
            url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git",
            .exact("5.4.24")
        )
    ],
    targets: [
        .target(
            name: "LinphoneWrapper",
            dependencies: [
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources"
        )
    ]
)
