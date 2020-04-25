//
//  Services.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import AckeeTracker
import Foundation

struct World {
    var api: API
    var tokens: TokenRepository
    var tracker: Tracker
}

var Current: World = {
    let tokens = TokenRepository()
    let api = GoAPI(tokens: tokens, baseURL: URL(string: "https://api.puffery.app/")!)

    let trackingDisabled: Bool
    #if DEBUG
        trackingDisabled = true
    #else
        trackingDisabled = true
    #endif
    let ackee = AckeeTracker(configuration: AckeeConfiguration(
        domainId: Bundle.main.infoDictionary!["ACKEE_DOMAIN_ID"] as! String,
        serverUrl: URL(string: Bundle.main.infoDictionary!["ACKEE_SERVER_URL"] as! String)!,
        appUrl: URL(string: Bundle.main.infoDictionary!["ACKEE_APP_URL"] as! String)!,
        disabled: trackingDisabled
    ))
    return World(api: api, tokens: tokens, tracker: ackee)
}()
