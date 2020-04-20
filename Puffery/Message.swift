//
//  Message.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: UUID = UUID()

    var title: String
    var channel: Channel
//    var triggerDate: Date
    var color: Color // TODO: Later own type

    enum Color: String, Codable {
        case blue, orange, green, red
    }
}

extension Message {
    static var testflight: Message {
        Message(
            title: "New TestFlight version available",
            channel: .puffery,
            color: .orange
        )
    }

    static var dockerImage: Message {
        Message(
            title: "New Docker image pushed",
            channel: .puffery,
            color: .blue
        )
    }
}
