//
//  Channel.swift
//  Puffery
//
//  Created by Valentin Knabel on 18.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

struct Channel: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
}

extension Channel {
    static var puffery: Channel {
        Channel(name: "Puffery")
    }
    
    static var plants: Channel {
        Channel(name: "Plants")
    }
}
