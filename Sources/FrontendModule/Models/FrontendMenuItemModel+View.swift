//
//  MenuModel+View.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 11. 15..
//

import FeatherCore

extension FrontendMenuItemModel: TemplateDataRepresentable {

    var templateData: TemplateData {
        .dictionary([
            "id": id,
            "icon": icon,
            "label": label,
            "url": url,
            "priority": priority,
            "targetBlank": targetBlank,
            "permission": permission,
        ])
    }
}
