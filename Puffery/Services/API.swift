//
//  API.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation

open class API: ObservableObject {
    func docs() -> Endpoint<String?> { fatalError() }
    func createChannel(title _: String, deviceToken _: String) -> Endpoint<Void> { fatalError() }
    func messages() -> Endpoint<[Message]> { fatalError() }
    func messages(ofChannel _: Channel) -> Endpoint<[Message]> { fatalError() }
    func subscribe(device _: String, publicChannel _: String) -> Endpoint<Void> { fatalError() }
    func notify(title _: String, body _: String, privateChannelToken _: String) -> Endpoint<Void> { fatalError() }
    func publicChannels() -> Endpoint<[Channel]> { fatalError() }
    func privateChannels() -> Endpoint<[Channel]> { fatalError() }
}
