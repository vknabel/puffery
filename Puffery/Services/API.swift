//
//  API.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation

protocol API {
    func docs() -> Endpoint<String?>

    func register(user createUser: CreateUserRequest) -> Endpoint<TokenResponse>
    func login(user createUser: LoginUserRequest) -> Endpoint<Void>
    func profile() -> Endpoint<UserResponse>
    func updateProfile(credentials: UpdateCredentialsRequest) -> Endpoint<UserResponse>

    func confirmEmail(_ confirmation: String) -> Endpoint<Void>
    func confirmLogin(_ confirmation: String) -> Endpoint<TokenResponse>

    func create(device createDevice: CreateDeviceRequest) -> Endpoint<DeviceResponse>
    func createOrUpdate(device deviceToken: String, contents: CreateOrUpdateDeviceRequest) -> Endpoint<DeviceResponse>

    func createChannel(_ createChannel: CreateChannelRequest) -> Endpoint<SubscribedChannelResponse>
    func messages() -> Endpoint<[Message]>
    func messages(ofChannel: Channel) -> Endpoint<[MessageResponse]>
    func subscribe(_ createSubscription: CreateSubscriptionRequest) -> Endpoint<SubscribedChannelResponse>
    func channels() -> Endpoint<[SubscribedChannelResponse]>
    func sharedChannels() -> Endpoint<[SubscribedChannelResponse]>
    func ownChannels() -> Endpoint<[SubscribedChannelResponse]>

    func notify(_ createMessage: CreateMessageRequest) -> Endpoint<NotifyMessageResponse>
}
