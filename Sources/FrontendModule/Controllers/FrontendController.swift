//
//  FrontendController.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 03. 27..
//

import FeatherCore

struct FrontendController {
    
    func catchAllView(req: Request) throws -> EventLoopFuture<Response> {
        let futures: [EventLoopFuture<Response?>] = req.invokeAll("frontend-route")
        return req.eventLoop.findFirstValue(futures).unwrap(or: Abort(.notFound))
    }

    /// a helper method to render sitemap and rss feed
    private func renderContentList(_ req: Request,
                                   using template: String,
                                   filter: ((QueryBuilder<FrontendMetadataModel>) -> QueryBuilder<FrontendMetadataModel>)? = nil)
        -> EventLoopFuture<Response>
    {
        var qb = FrontendMetadataModel.query(on: req.db)
        .filter(\.$status == .published)
        .filter(\.$date <= Date())
        if let filter = filter {
            qb = filter(qb)
        }
        return qb.all()
        .mapEach(\.templateData)
        .flatMap { req.tau.render(template: template, context: ["list": .array($0)]) }
        .encodeResponse(status: .ok, headers: ["Content-Type": "text/xml; charset=utf-8"], for: req)
    }

    func sitemap(_ req: Request) throws -> EventLoopFuture<Response> {
        renderContentList(req, using: "Frontend/Sitemap")
    }
    
    func rss(_ req: Request) throws -> EventLoopFuture<Response> {
        renderContentList(req, using: "Frontend/Rss") { $0.filter(\.$feedItem == true) }
    }

    func robots(_ req: Request) throws -> EventLoopFuture<Response> {
        req.tau.render(template: "Frontend/Robots")
            .encodeResponse(status: .ok, headers: ["Content-Type": "text/plain; charset=utf-8"], for: req)
    }
}
