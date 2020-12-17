//
//  MenuModel+View.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 11. 15..
//

import FeatherCore

extension FrontendMenuModel: LeafDataRepresentable {

    var leafData: LeafData {
        .dictionary([
            "id": id,
            "key": key,
            "name": name,
            "notes": notes,
            "items": $items.value != nil ? items.sorted(by: { $0.priority > $1.priority }) : [],
        ])
    }
}
