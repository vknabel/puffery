//
//  ListChannelsIntentHandler.swift
//  Puffery Intents
//
//  Created by Valentin Knabel on 03.05.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Intents
import PufferyKit

// @objc class ListChannelsIntentHandler: NSObject, OwnChannelsIntentHandling, SubscribedChannelsIntentHandling {
//    func handle(intent _: OwnChannelsIntent, completion: @escaping (OwnChannelsIntentResponse) -> Void) {
//        handleChannelListResponse(endpoint: Current.api.ownChannels()) { result in
//            switch result {
//            case let .success(intentChannels):
//                let channelsIntentResponse = OwnChannelsIntentResponse(code: .success, userActivity: nil)
//                channelsIntentResponse.channels = intentChannels
//                completion(channelsIntentResponse)
//            case let .failure(error):
//                switch error.reason {
//                case .statusCode(401):
//                    completion(OwnChannelsIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
//                case _:
//                    completion(OwnChannelsIntentResponse(code: .failure, userActivity: nil))
//                }
//            }
//        }
//    }
//
//    func handle(intent _: SubscribedChannelsIntent, completion: @escaping (SubscribedChannelsIntentResponse) -> Void) {
//        handleChannelListResponse(endpoint: Current.api.sharedChannels()) { result in
//            switch result {
//            case let .success(intentChannels):
//                let channelsIntentResponse = SubscribedChannelsIntentResponse(code: .success, userActivity: nil)
//                channelsIntentResponse.channels = intentChannels
//                completion(channelsIntentResponse)
//            case let .failure(error):
//                switch error.reason {
//                case .statusCode(401):
//                    completion(SubscribedChannelsIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
//                case _:
//                    completion(SubscribedChannelsIntentResponse(code: .failure, userActivity: nil))
//                }
//            }
//        }
//    }
//
//    private func handleChannelListResponse(endpoint: Endpoint<[SubscribedChannelResponse]>, _ completion: @escaping (Result<[IntentChannel], FetchingError>) -> Void) {
//        endpoint.task { result in
//            switch result {
//            case let .success(subscribedChannels):
//                let intentChannels = subscribedChannels.map { subscribedChannel -> IntentChannel in
//                    let channel = IntentChannel(identifier: subscribedChannel.id.uuidString, display: subscribedChannel.title)
//                    channel.title = subscribedChannel.title
//                    channel.receiveOnlyKey = subscribedChannel.receiveOnlyKey
//                    channel.notifyKey = subscribedChannel.notifyKey
//                    return channel
//                }
//                completion(.success(intentChannels))
//            case let .failure(error):
//                completion(.failure(error))
//            }
//        }
//    }
// }
