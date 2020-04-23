import APNS
import Fluent
import Vapor

final class MessageController {
//    /// Returns a list of all `Todo`s.
//    func index(_ req: Request) throws -> Future<[Todo]> {
//        return Todo.query(on: req).all()
//    }

    func create(_ req: Request) throws -> Future<MessageResponse> {
        // TODO: Instead of Message, own Request without channelID
        // TODO: Actually push to apple for all subscriptions

        let user = try req.auth.require(User.self)
        let createMessage = try req.content.decode(CreateMessageRequest.self)

        return Subscription.find(req.parameters.get("subscription_id"), on: req.db, with: \.$channel).flatMap { subscription in
            guard let subscription = subscription, user.id == subscription.$user.id else {
                throw ApiError.channelNotFound
            }

            let message = try Message(
                channel: subscription.channel,
                title: createMessage.title,
                body: createMessage.body,
                color: createMessage.color
            )
            return message.create(on: req.db)
                .flatMapThrowing { _ in
                    try MessageResponse(message, subscription: subscription)
                }
        }
    }

    func publicNotify(_ req: Request) throws -> Future<NotifyMessageResponse> {
        let notifyKey = req.parameters.get("notify_key")
        let createMessage = try req.content.decode(CreateMessageRequest.self)
        return Channel.query(on: req.db)
            .filter(\.$notifyKey, .equal, notifyKey ?? "")
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError.channelNotFound
                }
                return channel
            }
            .flatMap { channel in
                let message = try Message(channel: channel, title: createMessage.title, body: createMessage.body, color: createMessage.body)
                return message.create(on: req.db).transform(to: self.notifyDevices(req, message: message)).flatMapThrowing { _ in
                    try NotifyMessageResponse(message)
                }
            }
    }

    func index(_ req: Request) throws -> Future<[MessageResponse]> {
        let user = try req.auth.require(User.self)

        return Subscription.find(req.parameters.get("subscription_id"), on: req.db)
            .flatMapThrowing { (subscription: Subscription?) -> Subscription in
                guard let subscription = subscription, subscription.$user.id == user.id else {
                    throw ApiError.channelNotFound
                }
                return subscription
            }
            .flatMap { (subscription: Subscription) in
                Message.query(on: req.db)
                    .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
                    .filter(\Message.$createdAt, .greaterThanOrEqual, subscription.createdAt ?? Date.distantPast)
                    .all()
                    .flatMapThrowing { messages in
                        try messages.map { message in
                            try MessageResponse(message, subscription: subscription)
                        }
                    }
            }
    }

    private func notifyDevices(_ req: Request, message: Message) -> Future<Void> {
        let alert = APNSwiftPayload.APNSwiftAlert(
            title: message.title,
            subtitle: message.channel.title,
            body: message.body,
            titleLocKey: nil,
            titleLocArgs: nil,
            actionLocKey: nil,
            locKey: nil,
            locArgs: nil,
            launchImage: nil
        )

        return DeviceToken.query(on: req.db)
            .join(User.self, on: \DeviceToken.$user.$id == \User.$id, method: .inner)
            .join(Subscription.self, on: \User.$id == \Subscription.$user.$id)
            .join(Channel.self, on: \Subscription.$channel.$id == \Channel.$id)
            .filter(Channel.self, \Channel.$id == message.$channel.id)
            .all()
            .flatMap { devices in
                let apnsSends = devices.map { device in
                    req.apns.send(alert, to: device.token)
                }
                return req.eventLoop.flatten(apnsSends)
            }
    }
}

struct CreateMessageRequest: Content {
    var title: String
    var body: String
    var color: String?
}

struct MessageResponse: Content {
    var id: UUID
    var title: String
    var body: String
    var color: String?
    var channel: UUID
    var createdAt: Date

    init(_ message: Message, subscription: Subscription) throws {
        precondition(message.$channel.id == subscription.$channel.id, "Message and Subscription must share the same Channel")
        id = try message.requireID()
        title = message.title
        body = message.body
        color = message.color
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
