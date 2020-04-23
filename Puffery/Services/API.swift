//
//  API.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import Combine

open class API: ObservableObject {
    func docs() -> Endpoint<String?> { fatalError() }
    func createChannel(title: String, deviceToken: String) -> Endpoint<Void> { fatalError() }
    func messages() -> Endpoint<[Message]> { fatalError() }
    func messages(ofChannel channel: Channel) -> Endpoint<[Message]> { fatalError() }
    func subscribe(device deviceToken: String, publicChannel: String) -> Endpoint<Void> { fatalError() }
    func notify(title: String, body: String, privateChannelToken: String) -> Endpoint<Void> { fatalError() }
    func publicChannels() -> Endpoint<[Channel]> { fatalError() }
    func privateChannels() -> Endpoint<[Channel]> { fatalError() }
}
