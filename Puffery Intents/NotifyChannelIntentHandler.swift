//
//  NotifyChannelIntentHandler.swift
//  Puffery Intents
//
//  Created by Valentin Knabel on 03.05.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Intents
import PufferyKit

@objc class NotifyChannelIntentHandler: NSObject, NotiyChannelIntentHandling {
    func handle(intent: NotiyChannelIntent, completion: @escaping (NotiyChannelIntentResponse) -> Void) {
        guard let notifyKey = intent.channel?.notifyKey else {
            completion(NotiyChannelIntentResponse(code: .failure, userActivity: nil))
            return
        }
        Current.api.notify(key: notifyKey, CreateMessageRequest(title: intent.title ?? "", body: intent.body ?? "", color: intent.color.toPuffery.rawValue)).task { result in
            switch result {
            case let .success(messageResponse):
                let intentResponse = NotiyChannelIntentResponse(code: .success, userActivity: nil)
                intentResponse.message = IntentMessage(fromPuffery: messageResponse)
                completion(intentResponse)
            case let .failure(error):
                switch error.reason {
                case .statusCode(401):
                    completion(NotiyChannelIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
                case _:
                    completion(NotiyChannelIntentResponse(code: .failure, userActivity: nil))
                }
            }
        }
    }

    // MARK: Resolve

    func resolveTitle(for intent: NotiyChannelIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let title = intent.title {
            completion(INStringResolutionResult.success(with: title))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }

    func resolveBody(for intent: NotiyChannelIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let body = intent.body {
            completion(INStringResolutionResult.success(with: body))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }

    func resolveColor(for intent: NotiyChannelIntent, with completion: @escaping (IntentColorResolutionResult) -> Void) {
        completion(IntentColorResolutionResult.success(with: intent.color))
    }

    func resolveChannel(for intent: NotiyChannelIntent, with completion: @escaping (IntentChannelResolutionResult) -> Void) {
        if let intentChannel = intent.channel {
            completion(IntentChannelResolutionResult.success(with: intentChannel))
        } else {
            Current.api.ownChannels().task { result in
                if case let .success(ownChannels) = result {
                    completion(IntentChannelResolutionResult.disambiguation(with: ownChannels.map(IntentChannel.init(fromPuffery:))))
                }
            }
        }
    }
}
