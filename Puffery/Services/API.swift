//
//  API.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import Overture

final class API: ObservableObject {
    private let defaultStrategy: RequestFetchingStrategy
    private(set) lazy var jsonDecoder = updateObject(JSONDecoder())
    private(set) lazy var jsonEncoder = updateObject(JSONEncoder())

    init(baseURL: URL) {
        let internalStrategy = URLSessionRequestFetchingStrategy(baseURL: baseURL)
        defaultStrategy = LoggingRequestFetchingStrategy(internalStrategy) {
            guard case let .failure(error) = $0 else {
                return
            }
            print("Request failed: \(error)")
        }
    }

    private func endpoint(_ strategy: RequestFetchingStrategy? = nil) -> Endpoint<Data?> {
        Endpoint(strategy: strategy ?? defaultStrategy)
            .update { $0.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type") }
    }

    func docs() -> Endpoint<String?> {
        endpoint().get().compactMap { String(data: $0, encoding: .utf8) }
    }

    func createChannel(title: String, deviceToken: String) -> Endpoint<Void> {
        endpoint().post("channel", "create")
            .encoding(body: ["title": title, "deviceId": deviceToken], using: jsonEncoder.encode)
            .ignoreValue()
    }

    func messages(ofDevice deviceToken: String) -> Endpoint<[Message]> {
        endpoint()
            .get("channel", deviceToken, "notifications")
            .decoding(jsonDecoder.decode)
    }

    func messages(ofChannel channel: Channel) -> Endpoint<[Message]> {
        endpoint()
            .get("channel", channel.id, "notifications")
            .decoding(jsonDecoder.decode)
    }

    func subscribe(device deviceToken: String, publicChannel: String) -> Endpoint<Void> {
        endpoint()
            .post("channel", "subscribe")
            .encoding(body: ["channelId": publicChannel, "deviceId": deviceToken], using: jsonEncoder.encode)
            .ignoreValue()
    }

    func notify(title: String, body: String, privateChannelToken: String) -> Endpoint<Void> {
        endpoint().post("notify").encoding(body: [
            "title": title,
            "body": body,
            "channelToken": privateChannelToken,
        ], using: jsonEncoder.encode)
            .ignoreValue()
    }

//    func channels(deviceToken: String) -> Endpoint<[Channel]> // TODO: geht nicht mehr!!

    func publicChannels(device deviceToken: String) -> Endpoint<[Channel]> {
        endpoint().get("channels", deviceToken, "public")
            .decoding(jsonDecoder.decode)
    }

    func privateChannels(device deviceToken: String) -> Endpoint<[Channel]> {
        endpoint().get("channels", deviceToken, "private")
            .decoding(jsonDecoder.decode)
    }
}
