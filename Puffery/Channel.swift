//
//  Channel.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

typealias Channel = SubscribedChannelResponse

extension Channel: Identifiable {}

#if DEBUG
    extension Channel {
        static var puffery: Channel {
            Channel(id: UUID(), title: "Puffery", receiveOnlyKey: UUID().uuidString, notifyKey: UUID().uuidString)
        }

        static var plants: Channel {
            Channel(id: UUID(), title: "Plants", receiveOnlyKey: UUID().uuidString, notifyKey: UUID().uuidString)
        }
    }
#endif
