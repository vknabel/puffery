//
//  Services.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

public struct World {
    public var config: Config
    public var api: API
    public var store: Store
}

public var Current: World = {
    let config = Config.prod()
    var store = Store()
    let api = VaporAPI(baseURL: config.apiURL)
    return World(config: config, api: api, store: store)
}()
