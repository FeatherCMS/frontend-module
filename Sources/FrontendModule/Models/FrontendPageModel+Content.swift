//
//  FrontendPageModel+Content.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 07. 22..
//

import FeatherCore

extension FrontendPageModel: MetadataRepresentable {

    var metadata: Metadata { .init(slug: title.slugify(), title: title) }
}
