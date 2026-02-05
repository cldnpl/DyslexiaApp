// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Leggy",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Leggy",
            targets: ["AppModule"],
            bundleIdentifier: "-.Leggy",
            teamIdentifier: "H4M7KJL5DT",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.yellow),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "To scan texts and transport them in the application")
            ],
            appCategory: .education
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: [
                "Leggy 2.swiftpm",
                "scan_assets.swift"
            ],
            resources: [
                .process("Font")
            ]
        )
    ],
    swiftLanguageModes: [.version("6")]
)