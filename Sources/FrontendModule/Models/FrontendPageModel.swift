//
//  FrontendPageModel.swift
//  FrontendModule
//
//  Created by Tibor Bödecs on 2020. 06. 07..
//

import FeatherCore

final class FrontendPageModel: ViperModel {
    typealias Module = FrontendModule

    static let name = "pages"

    struct FieldKeys {
        static var title: FieldKey { "title" }
        static var content: FieldKey { "content" }
        
    }

    // MARK: - fields

    @ID() var id: UUID?
    @Field(key: FieldKeys.title) var title: String
    @Field(key: FieldKeys.content) var content: String

    init() { }
    
    init(id: UUID? = nil,
         title: String,
         content: String)
    {
        self.id = id
        self.title = title
        self.content = content
    }
}
