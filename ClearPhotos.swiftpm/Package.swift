// swift-tools-version: 5.9

// Bu paket, uygulamanın "Swift Playgrounds" (iPad ve Mac) sürümüdür.
// Xcode GEREKTİRMEZ. Bu klasörü (ClearPhotos.swiftpm) Swift Playgrounds ile aç.
//
// Not: Bu manifest yalnızca Swift Playgrounds / Xcode içinde derlenir; çünkü
// aşağıdaki "AppleProductTypes" modülü Apple'ın araçlarına özeldir.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "ClearPhotos",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "ClearPhotos",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.ClearPhotos",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            capabilities: [
                .photoLibrary(purposeString: "ClearPhotos yalnizca senin sectigin fotograf ve videolari gostermek ve senin onayinla silmek icin galerine erisir. Hicbir veri cihazindan disari cikmaz.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
