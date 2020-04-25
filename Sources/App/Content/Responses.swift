import Vapor

struct UserResponse: Content {
    var id: UUID
    var email: String?
}

struct TokenResponse: Content {
    var token: String
    var user: UserResponse
}

struct SubscribedChannelResponse: Content {
    /// Actually the ID of the Subscription!
    var id: UUID
    var title: String
    var receiveOnlyKey: String
    var notifyKey: String?
}

struct MessageResponse: Content {
    var id: UUID
    var title: String
    var body: String
    var colorName: String?
    var channel: UUID
    var createdAt: Date

    init(_ message: Message, subscription: Subscription) throws {
        precondition(message.$channel.id == subscription.$channel.id, "Message and Subscription must share the same Channel")
        id = try message.requireID()
        title = message.title
        body = message.body
        colorName = message.color
        channel = try subscription.requireID()
        createdAt = message.createdAt ?? Date()
    }
}

struct NotifyMessageResponse: Content {
    var id: UUID
    var title: String
    var body: String
    var color: String?
    var createdAt: Date

    init(_ message: Message) throws {
        id = try message.requireID()
        title = message.title
        body = message.body
        color = message.color
        createdAt = message.createdAt ?? Date()
    }
}

struct DeviceResponse: Content {
    var id: DeviceToken.IDValue
    var token: String
    var isProduction: Bool
}
