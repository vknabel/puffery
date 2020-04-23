//
//  GoAPI.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//


import Foundation
import Overture

final class GoAPI: API {
    private let defaultStrategy: RequestFetchingStrategy
    private(set) lazy var jsonDecoder = updateObject(JSONDecoder())
    private(set) lazy var jsonEncoder = updateObject(JSONEncoder())
    
    private let tokens: TokenRepository

    init(tokens: TokenRepository, baseURL: URL) {
        self.tokens = tokens
        let internalStrategy = URLSessionRequestFetchingStrategy(baseURL: baseURL)
        defaultStrategy = LoggingRequestFetchingStrategy(internalStrategy) {
            switch $0 {
            case let .failure(error):
                print("Request failed: \(error)")
            case let .success(value):
                print("Request passed: \(value)")
            }
        }
    }

        private func endpoint(_ strategy: RequestFetchingStrategy? = nil) -> Endpoint<Data?> {
            Endpoint(strategy: strategy ?? defaultStrategy)
                .update { $0.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type") }
        }

        override func docs() -> Endpoint<String?> {
            endpoint().get().compactMap { String(data: $0, encoding: .utf8) }
        }

        override func createChannel(title: String, deviceToken: String) -> Endpoint<Void> {
            endpoint().post("channel", "create")
                .encoding(body: ["title": title, "deviceId": deviceToken], using: jsonEncoder.encode)
                .ignoreValue()
        }

        override func messages() -> Endpoint<[Message]> {
            endpoint()
                .get("channel", tokens.latestDeviceToken ?? "", "notifications")
                .decoding(jsonDecoder.decode)
        }

        override func messages(ofChannel channel: Channel) -> Endpoint<[Message]> {
            endpoint()
                .get("channel", channel.id, "notifications")
                .decoding(jsonDecoder.decode)
        }

        override func subscribe(device deviceToken: String, publicChannel: String) -> Endpoint<Void> {
            endpoint()
                .post("channel", "subscribe")
                .encoding(body: ["channelId": publicChannel, "deviceId": deviceToken], using: jsonEncoder.encode)
                .ignoreValue()
        }

        override func notify(title: String, body: String, privateChannelToken: String) -> Endpoint<Void> {
            endpoint().post("notify").encoding(body: [
                "title": title,
                "body": body,
                "channelToken": privateChannelToken,
            ], using: jsonEncoder.encode)
                .ignoreValue()
        }

    //    func channels() -> Endpoint<[Channel]> // TODO: geht nicht mehr!!

        override func publicChannels() -> Endpoint<[Channel]> {
            endpoint().get("channels", tokens.latestDeviceToken ?? "", "public")
                .decoding(jsonDecoder.decode)
        }

        override func privateChannels() -> Endpoint<[Channel]> {
            endpoint().get("channels", tokens.latestDeviceToken ?? "", "private")
                .decoding(jsonDecoder.decode)
        }
    }
