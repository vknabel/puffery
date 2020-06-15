import APIDefinition
import Vapor

extension APIDefinition.ConfirmedEmailResponse: Content {}
extension APIDefinition.CreateChannelRequest: Content {}
extension APIDefinition.CreateDeviceRequest: Content {}
extension APIDefinition.CreateMessageRequest: Content {}
extension APIDefinition.CreateOrUpdateDeviceRequest: Content {}
extension APIDefinition.CreateSubscriptionRequest: Content {}
extension APIDefinition.CreateUserRequest: Content {}
extension APIDefinition.DeviceResponse: Content {}
extension APIDefinition.LoginAttemptResponse: Content {}
extension APIDefinition.LoginUserRequest: Content {}
extension APIDefinition.MessageResponse: Content {}
extension APIDefinition.NotifyMessageResponse: Content {}
extension APIDefinition.SubscribedChannelResponse: Content {}
extension APIDefinition.SubscribedChannelDeletedResponse: Content {}
extension APIDefinition.TokenResponse: Content {}
extension APIDefinition.UpdateProfileRequest: Content {}
extension APIDefinition.UserResponse: Content {}

extension MessageResponse {
    init(_ message: Message, subscription: Subscription) throws {
        precondition(message.$channel.id == subscription.$channel.id, "Message and Subscription must share the same Channel")
        self.init(
            id: try message.requireID(),
            title: message.title,
            body: message.body,
            colorName: message.color,
            channel: try subscription.requireID(),
            createdAt: message.createdAt ?? Date()
        )
    }
}

extension NotifyMessageResponse {
    init(_ message: Message) throws {
        self.init(
            id: try message.requireID(),
            title: message.title,
            body: message.body,
            color: message.color,
            createdAt: message.createdAt ?? Date()
        )
    }
}
