//
//  File.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 08. 23..
//

import FeatherCore

@_cdecl("createFrontendModule")
public func createFrontendModule() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(FrontendBuilder()).toOpaque()
}

public final class FrontendBuilder: ViperBuilder {

    public override func build() -> ViperModule {
        FrontendModule()
    }
}
