//
//  VaporAPI.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Foundation
import Overture

final class VaporAPI: API {
    private let defaultStrategy: RequestFetchingStrategy
    private(set) lazy var jsonDecoder = updateObject(JSONDecoder(), mut(\JSONDecoder.dateDecodingStrategy, .iso8601))
    private(set) lazy var jsonEncoder = updateObject(JSONEncoder(), mut(\JSONEncoder.dateEncodingStrategy, .iso8601))

    private let tokens: TokenRepository

    init(tokens: TokenRepository, baseURL: URL) {
        self.tokens = tokens
        let internalStrategy = URLSessionRequestFetchingStrategy(baseURL: baseURL)
        defaultStrategy = LoggingRequestFetchingStrategy(internalStrategy) {
            switch $0 {
            case let .failure(error):
                if let request = error.request, let description = error.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    print("Request failed: \(request) \(error.reason)\n    \(description)")
                } else {
                    print("Request failed: \(error)")
                }
            case let .success(value):
                print("Request passed: \(value)")
            }
        }
    }

    private func endpoint(_ strategy: RequestFetchingStrategy? = nil) -> Endpoint<Data?> {
        Endpoint(strategy: strategy ?? defaultStrategy)
            .update { $0.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type") }
            .update {
                if let sessionToken = self.tokens.sessionToken {
                    $0.addValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
                }
            }
            .handle { fetchingError in
                if case .statusCode(401) = fetchingError.reason {
                    Current.tokens.sessionToken = nil // TODO: changes not triggered
                }
            }
    }

    func docs() -> Endpoint<String?> {
        endpoint().get().compactMap { String(data: $0, encoding: .utf8) }
    }

    func register(user createUser: CreateUserRequest) -> Endpoint<TokenResponse> {
        endpoint().post("register")
            .encoding(body: createUser, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, TokenResponse.self)
            .perform { tokenResponse in
                self.tokens.sessionToken = tokenResponse.token
            }
    }

    func login(user credentials: LoginUserRequest) -> Endpoint<Void> {
        endpoint().post("login")
            .encoding(body: credentials, using: jsonEncoder.encode)
            .ignoreValue()
    }

    func profile() -> Endpoint<UserResponse> {
        endpoint().get("profile")
            .decoding(jsonDecoder.decode, UserResponse.self)
    }

    func updateProfile(credentials: UpdateCredentialsRequest) -> Endpoint<UserResponse> {
        endpoint().put("profile")
            .encoding(body: credentials, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, UserResponse.self)
    }

    func confirmEmail(_ confirmation: String) -> Endpoint<Void> {
        endpoint().put("confirmations", "email", confirmation)
            .ignoreValue()
    }

    func confirmLogin(_ confirmation: String) -> Endpoint<TokenResponse> {
        endpoint().post("confirmations", "login", confirmation)
            .decoding(jsonDecoder.decode, TokenResponse.self)
            .perform { tokenResponse in
                self.tokens.sessionToken = tokenResponse.token
            }
    }

    func create(device createDevice: CreateDeviceRequest) -> Endpoint<DeviceResponse> {
        var createDevice = createDevice
        #if DEBUG
            createDevice.isProduction = false
        #endif
        return endpoint().post("devices")
            .encoding(body: createDevice, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, DeviceResponse.self)
            .perform { deviceResponse in
                self.tokens.latestDeviceToken = deviceResponse.token
            }
    }

    func createOrUpdate(device deviceToken: String, contents createOrUpdateDevice: CreateOrUpdateDeviceRequest) -> Endpoint<DeviceResponse> {
        var createOrUpdateDevice = createOrUpdateDevice
        #if DEBUG
            createOrUpdateDevice.isProduction = false
        #endif
        return endpoint().put("devices", deviceToken)
            .encoding(body: createOrUpdateDevice, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, DeviceResponse.self)
            .perform { deviceResponse in
                self.tokens.latestDeviceToken = deviceResponse.token
            }
    }

    func createChannel(_ createChannel: CreateChannelRequest) -> Endpoint<SubscribedChannelResponse> {
        endpoint().post("channels")
            .encoding(body: createChannel, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func messages() -> Endpoint<[Message]> {
        endpoint()
            .get("channels", "messages")
            .decoding(jsonDecoder.decode)
    }

    func messages(ofChannel channel: Channel) -> Endpoint<[Message]> {
        endpoint()
            .get("channels", channel.id.uuidString, "messages")
            .decoding(jsonDecoder.decode)
    }

    func subscribe(_ createSubscription: CreateSubscriptionRequest) -> Endpoint<SubscribedChannelResponse> {
        endpoint()
            .post("channels", "subscribe")
            .encoding(body: createSubscription, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func notify(_ createMessage: CreateMessageRequest) -> Endpoint<NotifyMessageResponse> {
        endpoint().post("notify").encoding(body: createMessage, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func channels() -> Endpoint<[SubscribedChannelResponse]> {
        endpoint().get("channels")
            .decoding(jsonDecoder.decode)
    }
}
