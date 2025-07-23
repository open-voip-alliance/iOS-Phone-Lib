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
        .package(url: "https://github.com/JohannesNevels/Swinject.git", branch: "master"),
        .package(path: "../LinphoneWrapper")
    ],
    targets: [
        .target(
            name: "iOSPhoneLib",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "LinphoneWrapper", package: "LinphoneWrapper")
            ],
            path: "iOSPhoneLib",
            resources: [
                .process("iOSVoIPLib/Resources/ringback.wav"),
                .process("PIL/Localizable.stringsdict"),
            ]
        ),
    ]
)
