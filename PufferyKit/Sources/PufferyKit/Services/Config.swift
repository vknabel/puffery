//
//  Config.swift
//  Puffery
//
//  Created by Valentin Knabel on 25.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation

public struct Config {
    public var apiURL: URL
}

extension Config {
    public static func prod() -> Config {
        Config(
            apiURL: URL(string: Bundle.main.infoDictionary!["PUFFERY_API_URL"] as! String)!
        )
    }
}
