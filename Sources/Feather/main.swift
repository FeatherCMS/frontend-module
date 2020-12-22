//
//  main.swift
//  Feather
//
//  Created by Tibor Bodecs on 2019. 12. 17..
//

import FeatherCore

import FluentSQLiteDriver
import LiquidLocalDriver

import SystemModule
import UserModule
import ApiModule
import AdminModule
import BlogModule

import FrontendModule


/// setup metadata delegate object
Feather.metadataDelegate = FrontendMetadataDelegate()

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let feather = try Feather(env: env)
defer { feather.stop() }

try feather.configure(database: .sqlite(.file("db.sqlite")),
                      databaseId: .sqlite,
                      fileStorage: .local(publicUrl: Application.baseUrl, publicPath: Application.Paths.public, workDirectory: "assets"),
                      fileStorageId: .local,
                      modules: [
                        SystemBuilder(),
                        UserBuilder(),
                        AdminBuilder(),
                        ApiBuilder(),
                        BlogBuilder(),
                        FrontendBuilder(),
                      ])

if feather.app.isDebug {
    try feather.reset(resourcesOnly: true)
}

try feather.start()
