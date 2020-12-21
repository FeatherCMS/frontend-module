// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "frontend-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "FrontendModule", targets: ["FrontendModule"]),
        .library(name: "FrontendModuleApi", targets: ["FrontendModuleApi"]),
    ],
    dependencies: [
        /// feather core
        .package(url: "https://github.com/FeatherCMS/feather-core", from: "1.0.0-beta"),
        /// drivers
//        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
//        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.2.0-beta"),
        /// core modules
//        .package(url: "https://github.com/FeatherCMS/system-module", from: "1.0.0-beta"),
//        .package(url: "https://github.com/FeatherCMS/api-module", from: "1.0.0-beta"),
//        .package(url: "https://github.com/FeatherCMS/admin-module", from: "1.0.0-beta"),
//        .package(url: "https://github.com/FeatherCMS/user-module", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "FrontendModuleApi"),
        .target(name: "FrontendModule", dependencies: [
            .target(name: "FrontendModuleApi"),
            .product(name: "FeatherCore", package: "feather-core"),
        ],
        resources: [
            .copy("Bundle"),
        ]),
//        @NOTE: https://bugs.swift.org/browse/SR-8658
//        .target(name: "Feather", dependencies: [
//            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
//            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
//
//            /// feather
//            .product(name: "FeatherCore", package: "feather-core"),
//            /// core modules
//            .product(name: "SystemModule", package: "system-module"),
//            .product(name: "ApiModule", package: "api-module"),
//            .product(name: "AdminModule", package: "admin-module"),
//            .product(name: "UserModule", package: "user-module"),
//
//            .target(name: "FrontendModule"),
//        ]),
        .testTarget(name: "FrontendModuleTests", dependencies: [
            .target(name: "FrontendModule"),
        ])
    ]
)
