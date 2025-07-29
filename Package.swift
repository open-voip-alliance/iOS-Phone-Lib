// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "iOSPhoneLib",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "iOSPhoneLib",
            targets: ["iOSPhoneLib"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohannesNevels/Swinject.git", .exact("2.9.2")),
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", .exact("5.4.24"))
    ],
    targets: [
        .target(
            name: "LinphoneWrapper",
            dependencies: [
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "LinphoneWrapper/Sources"
        ),
        .target(
            name: "iOSPhoneLib",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
                "LinphoneWrapper"
            ],
            path: "iOSPhoneLib",
            resources: [
                .process("iOSVoIPLib/Resources/ringback.wav"),
                .process("PIL/Localizable.stringsdict"),
            ]
        ),
    ]
)
