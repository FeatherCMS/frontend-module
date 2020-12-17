// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "frontend-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "FrontendModule", targets: ["FrontendModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/binarybirds/feather-core", from: "1.0.0-beta"),
        
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.2.0-beta"),
        
        .package(name: "system-module", url: "https://github.com/feather-modules/system", from: "1.0.0-beta"),
        .package(name: "user-module", url: "https://github.com/feather-modules/user", from: "1.0.0-beta"),
        .package(name: "admin-module", url: "https://github.com/feather-modules/admin", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "FrontendApi"),
        .target(name: "FrontendModule", dependencies: [
            .target(name: "FrontendApi"),
            .product(name: "FeatherCore", package: "feather-core"),
        ],
        resources: [
            .copy("Bundle"),
        ]),
        .target(name: "Feather", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
            
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            
            .product(name: "SystemModule", package: "system-module"),
            .product(name: "UserModule", package: "user-module"),
            .product(name: "AdminModule", package: "admin-module"),

            .target(name: "FrontendModule"),
        ]),
        .testTarget(name: "FrontendModuleTests", dependencies: [
            .target(name: "FrontendModule"),
        ])
    ]
)
