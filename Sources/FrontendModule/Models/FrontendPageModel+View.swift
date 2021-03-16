//
//  FrontendPageModel+View.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 06. 09..
//

import FeatherCore

extension FrontendPageModel: TemplateDataRepresentable {

    var templateData: TemplateData {
        .dictionary([
            "id": id,
            "title": title,
            "content": content,
        ])
    }    
}
