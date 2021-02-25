//
//  FrontendModule.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 01. 26..
//

import FeatherCore

final class FrontendModule: ViperModule {

    static let name = "frontend"
    var priority: Int { 2000 }
    
    var router: ViperRouter? = FrontendRouter()
    
    var migrations: [Migration] {
        [
            FrontendMigration_v1_0_0()
        ]
    }

    static var bundleUrl: URL? {
        Bundle.module.resourceURL?.appendingPathComponent("Bundle")
    }

    func boot(_ app: Application) throws {
        app.databases.middleware.use(MetadataModelMiddleware<FrontendPageModel>())
        /// install
        app.hooks.register("model-install", use: modelInstallHook)
        app.hooks.register("user-permission-install", use: userPermissionInstallHook)
        app.hooks.register("system-variables-install", use: systemVariablesInstallHook)
        /// routes
        app.hooks.register("routes", use: (router as! FrontendRouter).routesHook)
        app.hooks.register("admin-routes", use: (router as! FrontendRouter).adminRoutesHook)
        app.hooks.register("frontend-route", use: frontendRouteHook)
        /// leaf
        app.hooks.register("leaf-admin-menu", use: leafAdminMenuHook)
        /// cache
        app.hooks.register("prepare-request-cache", use: prepareRequestCacheHook)
        /// page
        app.hooks.register("frontend-home-page", use: frontendHomePageHook)
        /// css
        app.hooks.register("css", use: cssHook)
    }

    func metadataQueryJoinHook<T: ViperModel & MetadataRepresentable>(args: HookArguments) -> QueryBuilder<T> {
        let qb = args["query-builder"] as! QueryBuilder<T>
        return qb.join(FrontendMetadataModel.self, on: \FrontendMetadataModel.$reference == \T._$id)
                    .filter(FrontendMetadataModel.self, \.$module == T.Module.name)
                    .filter(FrontendMetadataModel.self, \.$model == T.name)

    }

    func leafDataGenerator(for req: Request) -> [String: LeafDataGenerator]? {
        var res: [String: LeafDataGenerator]? = [:]
        
        let menus = req.cache["frontend.menus"] as? [String: LeafDataRepresentable] ?? [:]
        res?["menus"] = .lazy(LeafData.dictionary(menus))

        return res
    }
    

    func cssHook(args: HookArguments) -> [[String: Any]] {
        [
            [
                "name": "frontend",
                "priority": 0,
            ],
            /*
            [
                "name": "custom",
                "priority": 1000,
                "snippet": """
                    body { margin: 0; padding: 0; }
                """,
            ],
            */
        ]
    }

    // MARK: - hooks

    func prepareRequestCacheHook(args: HookArguments) -> EventLoopFuture<[String: Any?]> {
        let req = args["req"] as! Request
        return FrontendMenuModel.query(on: req.db).with(\.$items).all().map { menus in
            var items: [String: LeafDataRepresentable] = [:]
            for menu in menus {
                items[menu.key] = menu.leafData
            }
            return items
        }
        .map { items in
             ["frontend.menus": items as Any?]
        }
    }
    
    // MARK: - hooks

    func leafAdminMenuHook(args: HookArguments) -> LeafDataRepresentable {
        [
            "name": "Frontend",
            "icon": "layout",
            "permission": "frontend.module.access",
            "items": LeafData.array([
                [
                    "label": "Pages",
                    "url": "/admin/frontend/pages/",
                ],
                [
                    "url": "/admin/frontend/menus/",
                    "label": "Menus",
                    "permission": "frontend.menus.list",
                ],
                [
                    "url": "/admin/frontend/settings/",
                    "label": "Settings",
                    "permission": "frontend.settings.update",
                ],
                [
                    "url": "/admin/frontend/metadatas/",
                    "label": "Metadatas",
                    "permission": "frontend.metadatas.list",
                ]
            ])
        ]
    }
    
    func frontendRouteHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args["req"] as! Request
        
        return FrontendPageModel.queryJoinVisibleMetadata(path: req.url.path, on: req.db)
            .first()
            .flatMap { page -> EventLoopFuture<Response?> in
                guard let page = page else {
                    return req.eventLoop.future(nil)
                }
                /// if the content of a page has a page tag, then we respond with the corresponding page hook function
                let content = page.content.trimmingCharacters(in: .whitespacesAndNewlines)
                if content.hasPrefix("["), content.hasSuffix("-page]") {
                    let name = String(content.dropFirst().dropLast())
                    let args: HookArguments = ["page-metadata": page.joinedMetadata as Any]
                    if let future: EventLoopFuture<Response?> = req.invoke(name, args: args) {
                        return future
                    }
                }
                /// render the page with the filtered content
                var ctx = page.leafDataWithJoinedMetadata.dictionary!
                ctx["content"] = .string(page.filter(content, req: req))
                return req.leaf.render(template: "Frontend/Page", context: .init(ctx)).encodeOptionalResponse(for: req)
            }
    }
    
    /// renders the [frontend-home-page] content
    func frontendHomePageHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args["req"] as! Request
        let metadata = args["page-metadata"] as! Metadata

        return req.leaf.render(template: "Frontend/Home", context: [
            "metadata": metadata.leafData,
        ])
        .encodeOptionalResponse(for: req)
    }

}

