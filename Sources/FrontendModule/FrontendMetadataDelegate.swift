//
//  FrontendMetadataDelegate.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 12. 17..
//

import FeatherCore

public struct FrontendMetadataDelegate: MetadataDelegate {

    public init() {}

    /// query builder
    public func join<T: MetadataModel>(queryBuilder: QueryBuilder<T>) -> QueryBuilder<T> {
        queryBuilder.join(FrontendMetadataModel.self, on: \FrontendMetadataModel.$reference == \T._$id)
                    .filter(FrontendMetadataModel.self, \.$module == T.Module.name)
                    .filter(FrontendMetadataModel.self, \.$model == T.name)
    }
    
    public func filter<T: MetadataModel>(queryBuilder: QueryBuilder<T>, path: String) -> QueryBuilder<T> {
        queryBuilder.filter(FrontendMetadataModel.self, \.$slug == path.trimmingSlashes())
    }
    
    public func filter<T: MetadataModel>(queryBuilder: QueryBuilder<T>, before: Date) -> QueryBuilder<T> {
        queryBuilder.filter(FrontendMetadataModel.self, \.$date <= before)
    }
    
    public func filter<T: MetadataModel>(queryBuilder: QueryBuilder<T>, status: Metadata.Status) -> QueryBuilder<T> {
        queryBuilder.filter(FrontendMetadataModel.self, \.$status == status)
    }
    
    public func filterVisible<T: MetadataModel>(queryBuilder: QueryBuilder<T>) -> QueryBuilder<T> {
        queryBuilder.filter(FrontendMetadataModel.self, \.$status != .archived)
    }
    
    public func sortByDate<T: MetadataModel>(queryBuilder: QueryBuilder<T>, direction: DatabaseQuery.Sort.Direction) -> QueryBuilder<T> {
        queryBuilder.sort(FrontendMetadataModel.self, \.$date, direction)
    }
    
    /// viper model
    public func joinedMetadata<T: MetadataModel>(_ model: T) -> Metadata? {
        try? model.joined(FrontendMetadataModel.self).metadata
    }

    public func find<T: MetadataModel>(_ model: T.Type, reference: UUID, on db: Database) -> EventLoopFuture<Metadata?> {
        FrontendMetadataModel.query(on: db)
            .filter(\.$module == T.Module.name)
            .filter(\.$model == model.name)
            .filter(\.$reference == reference)
            .first()
            .map { $0?.metadata }
    }
    
    public func create(_ metadata: Metadata, on db: Database) -> EventLoopFuture<Void> {
        let model = FrontendMetadataModel()
        
        model.use(metadata)
        return model.create(on: db)
    }

    public func update(_ metadata: Metadata, on db: Database) -> EventLoopFuture<Void> {
        FrontendMetadataModel.query(on: db)
                    .filter(\.$module == metadata.module!)
                    .filter(\.$model == metadata.model!)
                    .filter(\.$reference == metadata.reference!)
                    .first()
                    .unwrap(or: Abort(.notFound))
                    .flatMap { model -> EventLoopFuture<Void> in
                        model.use(metadata)
                        return model.update(on: db)
                    }
    }

    public func delete(_ metadata: Metadata, on db: Database) -> EventLoopFuture<Void> {
        FrontendMetadataModel.query(on: db)
            .filter(\.$module == metadata.module!)
            .filter(\.$model == metadata.model!)
            .filter(\.$reference == metadata.reference!)
            .delete()
    }
}
