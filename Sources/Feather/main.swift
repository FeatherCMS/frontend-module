//
//  main.swift
//  Feather
//
//  Created by Tibor Bodecs on 2019. 12. 17..
//

import FeatherCore

import SystemModule
import CommonModule
import UserModule
import ApiModule
import AdminModule
import BlogModule
import SwiftyModule
import MarkdownModule
import FrontendModule

/// setup metadata delegate object
Feather.metadataDelegate = FrontendMetadataDelegate()

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let feather = try Feather(env: env)
defer { feather.stop() }

feather.useSQLiteDatabase()
feather.useLocalFileStorage()
feather.usePublicFileMiddleware()

try feather.configure([
    /// core
    SystemBuilder(),
    CommonBuilder(),
    UserBuilder(),
    ApiBuilder(),
    AdminBuilder(),
    FrontendBuilder(),
    /// other
    BlogBuilder(),
    SwiftyBuilder(),
    MarkdownBuilder(),
])

/// reset resources folder if we're in debug mode
if feather.app.isDebug {
//    try feather.resetPublicFiles()
//    try feather.copyTemplatesIfNeeded()
}

feather.app.http.server.configuration.hostname = Environment.get("SERVER_HOSTNAME") ?? "0.0.0.0"
feather.app.http.server.configuration.port = Int(Environment.get("SERVER_PORT") ?? "8080") ?? 8080

try feather.start()
