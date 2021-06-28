//
//  Events.swift
//  
//
//  Created by Valentin Knabel on 28.06.21.
//

import Foundation
import AckeeTracker
import protocol Apollo.Cancellable

public enum Events: String {
    case sendMessage = "1896d671-739f-49a7-9f57-54be921b11f7"
    case shareChannel = "9ceb5650-7bf2-44c6-a8e9-b04978c194a6"
    case example = "2c4a75ee-bd85-414f-ab83-4c9d60125387"
    case session = "5674418d-460e-42bc-80e3-5fc0a569c503"
    case external = "aababce7-a137-48b0-8375-a9cf7a024b24"
}

public enum EventKeys: String {
    case fromShortcut
    case fromApp
    
    case copyNotify
    case copyReceiveOnly
    case shareNotify
    case shareReceiveOnly
    
    case exampleCurl, exampleEmail, exampleShortcut
    case login, logout, delete, signup, changeEmail
}

extension AckeeTracker {
    @discardableResult
    public func action(
        _ event: Events,
        key: EventKeys,
        value: Decimal = 1.0,
        details: String? = nil,
        onSuccess: ((Action) -> Void)? = nil
    ) -> Cancellable {
        action(event.rawValue, attributes: CreateActionInput(key: key.rawValue, value: "\(value)", details: details), onSuccess: onSuccess)
    }
    
    @discardableResult
    public func action(
        _ event: Events,
        key: String,
        value: Decimal = 1.0,
        details: String? = nil,
        onSuccess: ((Action) -> Void)? = nil
    ) -> Cancellable {
        action(event.rawValue, attributes: CreateActionInput(key: key, value: "\(value)", details: details), onSuccess: onSuccess)
    }
}
