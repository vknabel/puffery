//
//  Channel.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

struct Channel: Codable {
    let title: String
    let token: String
    let publicId: String
}

extension Channel: Identifiable {
    var id: String { token }
}

extension Channel {
    static var puffery: Channel {
        Channel(title: "Puffery", token: UUID().uuidString, publicId: UUID().uuidString)
    }

    static var plants: Channel {
        Channel(title: "Plants", token: UUID().uuidString, publicId: UUID().uuidString)
    }
}
