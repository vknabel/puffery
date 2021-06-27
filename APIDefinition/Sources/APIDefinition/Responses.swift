import Foundation

public struct UserResponse: Codable, Equatable {
    public var id: UUID
    public var email: String?
    public var isConfirmed: Bool

    public init(id: UUID, email: String?, isConfirmed: Bool) {
        self.id = id
        self.email = email
        self.isConfirmed = isConfirmed
    }
}

public struct TokenResponse: Codable {
    public var token: String
    public var user: UserResponse

    public init(token: String, user: UserResponse) {
        self.token = token
        self.user = user
    }
}

public struct LoginAttemptResponse: Codable {
    public init() {}
}

public struct ConfirmedEmailResponse: Codable {
    public init() {}
}

public struct SubscribedChannelResponse: Codable, Hashable {
    /// Actually the ID of the Subscription!
    public var id: UUID
    public var title: String
    public var receiveOnlyKey: String
    public var notifyKey: String?
    public var isSilent: Bool

    public init(id: UUID, title: String, receiveOnlyKey: String, notifyKey: String?, isSilent: Bool) {
        self.id = id
        self.title = title
        self.receiveOnlyKey = receiveOnlyKey
        self.notifyKey = notifyKey
        self.isSilent = isSilent
    }
}

public struct SubscribedChannelStatisticsResponse: Codable, Hashable {
    public var notifiers: Int
    public var receivers: Int
    public var messages: Int

    public init(
        notifiers: Int,
        receivers: Int,
        messages: Int
    ) {
        self.notifiers = notifiers
        self.receivers = receivers
        self.messages = messages
    }
}

public struct SubscribedChannelDeletedResponse: Codable {
    public init() {}
}

public struct MessageResponse: Codable {
    public var id: UUID
    public var title: String
    public var body: String
    public var colorName: String?
    public var channel: UUID
    public var createdAt: Date

    public init(
        id: UUID,
        title: String,
        body: String,
        colorName: String?,
        channel: UUID,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.colorName = colorName
        self.channel = channel
        self.createdAt = createdAt
    }
}

public struct NotifyMessageResponse: Codable {
    public var id: UUID
    public var title: String
    public var body: String
    public var color: String?
    public var createdAt: Date

    public init(
        id: UUID,
        title: String,
        body: String,
        color: String?,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.color = color
        self.createdAt = createdAt
    }
}

public struct DeviceResponse: Codable {
    public var id: UUID
    public var token: String
    public var isProduction: Bool

    public init(
        id: UUID,
        token: String,
        isProduction: Bool
    ) {
        self.id = id
        self.token = token
        self.isProduction = isProduction
    }
}
