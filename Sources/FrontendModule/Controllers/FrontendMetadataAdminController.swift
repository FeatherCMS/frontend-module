//
//  FrontendContentAdminController.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 06. 09..
//

import FeatherCore
import Fluent

struct FrontendMetadataModelAdminController: ViperAdminViewController {
    
    typealias Module = FrontendModule
    typealias Model = FrontendMetadataModel
    typealias CreateForm = FrontendMetadataModelEditForm
    typealias UpdateForm = FrontendMetadataModelEditForm

    var listAllowedOrders: [FieldKey] = [
        FrontendMetadataModel.FieldKeys.slug,
        FrontendMetadataModel.FieldKeys.module,
        FrontendMetadataModel.FieldKeys.model,
    ]

    func listQuery(search: String, queryBuilder: QueryBuilder<FrontendMetadataModel>, req: Request) {
        queryBuilder.filter(\.$slug ~~ search)
        queryBuilder.filter(\.$title ~~ search)
    }
    
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        var future = req.eventLoop.future(model)
        if let key = model.imageKey {
            future = req.fs.delete(key: key).map { model }
        }
        return future
    }
}
