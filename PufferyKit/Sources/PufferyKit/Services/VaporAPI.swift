//
//  VaporAPI.swift
//  Puffery
//
//  Created by Valentin Knabel on 23.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import Foundation
import Overture

final class VaporAPI: API {
    private let defaultStrategy: RequestFetchingStrategy
    private(set) lazy var jsonDecoder = updateObject(JSONDecoder(), mut(\JSONDecoder.dateDecodingStrategy, .iso8601))
    private(set) lazy var jsonEncoder = updateObject(JSONEncoder(), mut(\JSONEncoder.dateEncodingStrategy, .iso8601))

    init(baseURL: URL) {
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
                if let sessionToken = Current.store.state.session.sessionToken {
                    $0.addValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
                }
            }
            .handle { fetchingError in
                if case .statusCode(401) = fetchingError.reason {
                    Current.store.commit(.updateSession(nil))
                }
            }
    }

    func docs() -> Endpoint<String?> {
        endpoint().get().compactMap { String(data: $0, encoding: .utf8) }
    }

    func register(user createUser: CreateUserRequest) -> Endpoint<TokenResponse> {
        endpoint().post("api", "v1", "register")
            .encoding(body: createUser, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, TokenResponse.self)
            .perform { tokenResponse in
                Current.store.commit(.updateSession(tokenResponse))
            }
    }

    func login(user credentials: LoginUserRequest) -> Endpoint<Void> {
        endpoint().post("api", "v1", "login")
            .encoding(body: credentials, using: jsonEncoder.encode)
            .ignoreValue()
    }

    func profile() -> Endpoint<UserResponse> {
        endpoint().get("api", "v1", "profile")
            .decoding(jsonDecoder.decode, UserResponse.self)
    }

    func updateProfile(credentials: UpdateProfileRequest) -> Endpoint<UserResponse> {
        endpoint().put("api", "v1", "profile")
            .encoding(body: credentials, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, UserResponse.self)
    }
    
    func deleteAccount() -> Endpoint<Void> {
        endpoint().delete("api", "v1", "profile")
            .ignoreValue()
    }

    func confirmEmail(_ confirmation: String) -> Endpoint<Void> {
        endpoint().put("api", "v1", "confirmations", "email", confirmation)
            .ignoreValue()
    }

    func confirmLogin(_ confirmation: String) -> Endpoint<TokenResponse> {
        endpoint().post("api", "v1", "confirmations", "login", confirmation)
            .decoding(jsonDecoder.decode, TokenResponse.self)
            .perform { tokenResponse in
                Current.store.commit(.updateSession(tokenResponse))
            }
    }

    func create(device createDevice: CreateDeviceRequest) -> Endpoint<DeviceResponse> {
        var createDevice = createDevice
        #if DEBUG
            createDevice.isProduction = false
        #endif
        return endpoint().post("api", "v1", "devices")
            .encoding(body: createDevice, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, DeviceResponse.self)
            .perform { deviceResponse in
                Current.store.commit(.updateDeviceToken(deviceResponse.token))
            }
    }

    func createOrUpdate(device deviceToken: String, contents createOrUpdateDevice: CreateOrUpdateDeviceRequest) -> Endpoint<DeviceResponse> {
        var createOrUpdateDevice = createOrUpdateDevice
        #if DEBUG
            createOrUpdateDevice.isProduction = false
        #endif
        return endpoint().put("api", "v1", "devices", deviceToken)
            .encoding(body: createOrUpdateDevice, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode, DeviceResponse.self)
            .perform { deviceResponse in
                Current.store.commit(.updateDeviceToken(deviceResponse.token))
            }
    }

    func createChannel(_ createChannel: CreateChannelRequest) -> Endpoint<SubscribedChannelResponse> {
        endpoint().post("api", "v1", "channels")
            .encoding(body: createChannel, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func messages(pagination: PaginationRequest) -> Endpoint<[Message]> {
        endpoint()
            .get("api", "v1", "channels", "messages")
            .query(["page": pagination.page.map(String.init), "limit": pagination.limit.map(String.init)])
            .decoding(jsonDecoder.decode)
    }

    func messages(ofChannel channel: Channel, pagination: PaginationRequest) -> Endpoint<[Message]> {
        endpoint()
            .get("api", "v1", "channels", channel.id.uuidString, "messages")
            .query(["page": pagination.page.map(String.init), "limit": pagination.limit.map(String.init)])
            .decoding(jsonDecoder.decode)
    }

    func subscribe(_ createSubscription: CreateSubscriptionRequest) -> Endpoint<SubscribedChannelResponse> {
        endpoint()
            .post("api", "v1", "channels", "subscribe")
            .encoding(body: createSubscription, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func update(subscription: SubscribedChannelResponse, updateSubscription: UpdateSubscriptionRequest) -> Endpoint<SubscribedChannelResponse> {
        endpoint()
            .post("api", "v1", "channels", subscription.id.uuidString)
            .encoding(body: updateSubscription, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func unsubscribe(_ subscription: SubscribedChannelResponse) -> Endpoint<SubscribedChannelDeletedResponse> {
        endpoint()
            .delete("api", "v1", "channels", subscription.id.uuidString)
            .encoding(body: subscription, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func notify(key notifyKey: String, _ createMessage: CreateMessageRequest) -> Endpoint<NotifyMessageResponse> {
        endpoint().post("api", "v1", "notify", notifyKey).encoding(body: createMessage, using: jsonEncoder.encode)
            .decoding(jsonDecoder.decode)
    }

    func channels() -> Endpoint<[SubscribedChannelResponse]> {
        endpoint().get("api", "v1", "channels")
            .decoding(jsonDecoder.decode)
    }

    func channel(id: UUID) -> Endpoint<SubscribedChannelResponse> {
        endpoint().get("api", "v1", "channels", id.uuidString)
            .decoding(jsonDecoder.decode)
    }

    func channelStats(id: UUID) -> Endpoint<SubscribedChannelStatisticsResponse> {
        endpoint().get("api", "v1", "channels", id.uuidString, "stats")
            .decoding(jsonDecoder.decode)
    }

    func sharedChannels() -> Endpoint<[SubscribedChannelResponse]> {
        endpoint().get("api", "v1", "channels", "shared")
            .decoding(jsonDecoder.decode)
    }

    func ownChannels() -> Endpoint<[SubscribedChannelResponse]> {
        endpoint().get("api", "v1", "channels", "own")
            .decoding(jsonDecoder.decode)
    }
}
