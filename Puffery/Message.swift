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
    var body: String
//    var channel: Channel
//    var triggerDate: Date
    var color: Color

    enum Color: String, Codable {
        case blue, orange, green, red, gray

        static var unspecified: Color {
            return .gray
        }
    }
}

#if DEBUG
    extension Message {
        static var testflight: Message {
            Message(
                title: "New TestFlight version available",
                body: "Version 123 has been build",
                color: .orange
            )
        }

        static var dockerImage: Message {
            Message(
                title: "New Docker image pushed",
                body: "Version 123 has been build",
                color: .blue
            )
        }
    }
#endif
