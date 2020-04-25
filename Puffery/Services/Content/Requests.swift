import Foundation

struct CreateUserRequest: Content {
    var email: String?
    var device: CreateDeviceRequest?
}

struct LoginUserRequest: Content {
    var email: String?
}

struct CreateChannelRequest: Content {
    var title: String
}

enum CreateSubscriptionRequest: Content {
    case notifyKey(String)
    case receiveOnlyKey(String)
    
    init(from decoder: Decoder) throws {
        if let notify = try? CreateNotifySubscription(from: decoder) {
            self = .notifyKey(notify.notifyKey)
        } else {
            let receiveOnly = try CreateSubscribeOnlySubscription(from: decoder)
            self = .receiveOnlyKey(receiveOnly.receiveOnlyKey)
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .notifyKey(key):
            try CreateNotifySubscription(notifyKey: key).encode(to: encoder)
        case let .receiveOnlyKey(key):
            try CreateSubscribeOnlySubscription(receiveOnlyKey: key).encode(to: encoder)
        }
    }

    private struct CreateNotifySubscription: Codable {
        var notifyKey: String
    }

    private struct CreateSubscribeOnlySubscription: Codable {
        var receiveOnlyKey: String
    }
}

struct CreateMessageRequest: Content {
    var title: String
    var body: String
    var color: String?
}

struct CreateDeviceRequest: Content {
    var token: String
    var isProduction: Bool?
}

struct CreateOrUpdateDeviceRequest: Content {
    var isProduction: Bool?
}
