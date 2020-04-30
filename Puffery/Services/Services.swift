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
    var config: Config
    var api: API
    var tracker: Tracker
    var store: Store
}

var Current: World = {
    let config = Config.prod()
    var store = Store()
    let api = VaporAPI(baseURL: config.apiURL)

    let trackingDisabled: Bool
    #if DEBUG
        trackingDisabled = true
    #else
        trackingDisabled = false
    #endif
    let ackee = AckeeTracker(configuration: AckeeConfiguration(
        domainId: config.ackeeDomainID,
        serverUrl: config.ackeeServerURL,
        appUrl: config.ackeeAppURL,
        disabled: trackingDisabled
    ))
    return World(config: config, api: api, tracker: ackee, store: store)
}()
