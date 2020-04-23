//
//  Services.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

struct World {
    var api: API
    var tokens: TokenRepository
}

var Current: World = {
    let tokens = TokenRepository()
    let api = GoAPI(tokens: tokens, baseURL: URL(string: "https://api.puffery.app/")!)
    return World(api: api, tokens: tokens)
}()
