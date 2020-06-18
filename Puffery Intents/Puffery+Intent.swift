//
//  SubscribedChannelResponse+Intent.swift
//  Puffery Intents
//
//  Created by Valentin Knabel on 03.05.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import PufferyKit

extension IntentChannel {
    convenience init(fromPuffery pufferyChannel: SubscribedChannelResponse) {
        self.init(identifier: pufferyChannel.id.uuidString, display: pufferyChannel.title)
        title = pufferyChannel.title
        receiveOnlyKey = pufferyChannel.receiveOnlyKey
        notifyKey = pufferyChannel.notifyKey
    }
}

extension IntentColor {
    init(fromPuffery pufferyColor: PufferyKit.Message.Color) {
        switch pufferyColor {
        case .blue:
            self = .blue
        case .gray:
            self = .gray
        case .green:
            self = .green
        case .orange:
            self = .orange
        case .pink:
            self = .pink
        case .purple:
            self = .purple
        case .red:
            self = .red
        case .yellow:
            self = .yellow
        }
    }

    var toPuffery: PufferyKit.Message.Color {
        switch self {
        case .blue:
            return .blue
        case .gray:
            return .gray
        case .green:
            return .green
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .unknown:
            return .unspecified
        }
    }
}

extension IntentMessage {
    convenience init(fromPuffery pufferyMessage: PufferyKit.NotifyMessageResponse) {
        self.init(identifier: pufferyMessage.id.uuidString, display: pufferyMessage.title)
        title = pufferyMessage.title
        body = pufferyMessage.body
        color = IntentColor(fromPuffery: pufferyMessage.color.flatMap(Message.Color.init(rawValue:)) ?? Message.Color.unspecified)
    }
}
