// swift-tools-version:5.3
import PackageDescription

let isLocalTestMode = false

var deps: [Package.Dependency] = [
    .package(url: "https://github.com/FeatherCMS/feather-core", from: "1.0.0-beta"),
]

var targets: [Target] = [
    .target(name: "FrontendModuleApi"),
    .target(name: "FrontendModule", dependencies: [
        .target(name: "FrontendModuleApi"),
        .product(name: "FeatherCore", package: "feather-core"),
    ],
    resources: [
        .copy("Bundle"),
    ]),
]

// @NOTE: https://bugs.swift.org/browse/SR-8658
if isLocalTestMode {
    deps.append(contentsOf: [
        /// drivers
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.2.0"),
        /// core modules
        .package(url: "https://github.com/FeatherCMS/system-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/common-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/api-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/admin-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/user-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/blog-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/swifty-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/markdown-module", from: "1.0.0-beta"),
    ])
    targets.append(contentsOf: [
        .target(name: "Feather", dependencies: [
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            /// feather
            .product(name: "FeatherCore", package: "feather-core"),
            /// core modules
            .product(name: "SystemModule", package: "system-module"),
            .product(name: "CommonModule", package: "common-module"),
            .product(name: "ApiModule", package: "api-module"),
            .product(name: "AdminModule", package: "admin-module"),
            .product(name: "UserModule", package: "user-module"),

            .product(name: "BlogModule", package: "blog-module"),
            .product(name: "SwiftyModule", package: "swifty-module"),
            .product(name: "MarkdownModule", package: "markdown-module"),

            .target(name: "FrontendModule"),
        ]),
        .testTarget(name: "FrontendModuleTests", dependencies: [
            .target(name: "FrontendModule"),
        ])
    ])
}

let package = Package(
    name: "frontend-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "FrontendModule", targets: ["FrontendModule"]),
        .library(name: "FrontendModuleApi", targets: ["FrontendModuleApi"]),
    ],
    dependencies: deps,
    targets: targets
)
