//
//  Metadata+Leaf.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 08. 29..
//

import FeatherCore

extension Metadata.Status: FormFieldOptionRepresentable {

    public var formFieldOption: FormFieldOption {
        .init(key: rawValue, label: localized)
    }
}

extension FrontendMetadataModel: LeafDataRepresentable {

    /// returns the LeafData types for a metadata
    var leafData: LeafData {
        .dictionary([
            "id": .string(id?.uuidString),
            "module": .string(module),
            "model": .string(model),
            "reference": .string(reference.uuidString),
            
            "title": .string(title),
            "excerpt": .string(excerpt),
            "imageKey": .string(imageKey),
            "date": .double(date.timeIntervalSinceReferenceDate),
            
            "slug": .string(slug),
            "status": .string(status.rawValue),
            "feedItem": .bool(feedItem),
            "canonicalUrl": .string(canonicalUrl),
            
            "filters": .array(filters),

            "css": .string(css),
            "js": .string(js),
        ])
    }
}
