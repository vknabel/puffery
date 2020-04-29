import Foundation

struct UserResponse: Content, Equatable {
    var id: UUID
    var email: String?
}

struct TokenResponse: Content {
    var token: String
    var user: UserResponse
}

struct SubscribedChannelResponse: Content, Equatable {
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
}

struct NotifyMessageResponse: Content {
    var id: UUID
    var title: String
    var body: String
    var color: String?
    var createdAt: Date
}

struct DeviceResponse: Content {
    var id: UUID
    var token: String
    var isProduction: Bool
}
