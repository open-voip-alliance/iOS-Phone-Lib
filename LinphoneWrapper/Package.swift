// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "iOSPhoneLib-Private",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "iOSPhoneLib-Private",
            targets: ["iOSPhoneLib-Private"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohannesNevels/Swinject.git", .exact("2.9.2")),
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", .exact("5.4.24"))
    ],
    targets: [
        .target(
            name: "iOSPhoneLib-Private",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources"
        ),
    ]
)
