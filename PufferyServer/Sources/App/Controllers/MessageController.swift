import APNS
import Fluent
import Vapor

final class MessageController {
//    /// Returns a list of all `Todo`s.
//    func index(_ req: Request) throws -> Future<[Todo]> {
//        return Todo.query(on: req).all()
//    }

    func create(_ req: Request) throws -> EventLoopFuture<MessageResponse> {
        // TODO: Instead of Message, own Request without channelID
        // TODO: Actually push to apple for all subscriptions

        let user = try req.auth.require(User.self)
        let createMessage = try req.content.decode(CreateMessageRequest.self)

        return Subscription.find(req.parameters.get("subscription_id"), on: req.db, with: \.$channel).flatMap { subscription in
            guard let subscription = subscription, user.id == subscription.$user.id else {
                throw ApiError(.channelNotFound)
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

    func publicNotify(_ req: Request) throws -> EventLoopFuture<NotifyMessageResponse> {
        let notifyKey = req.parameters.get("notify_key")
        let createMessage = try req.content.decode(CreateMessageRequest.self)
        return Channel.query(on: req.db)
            .filter(\.$notifyKey, .equal, notifyKey ?? "")
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError(.channelNotFound)
                }
                return channel
            }
            .flatMapThrowing { channel in
                try Message(channel: channel, title: createMessage.title, body: createMessage.body, color: createMessage.color)
            }
            .flatMap { message in self.saveAndNotify(req, message: message) }
            .flatMapThrowing { message in try NotifyMessageResponse(message) }
    }

    func index(_ req: Request) throws -> EventLoopFuture<[MessageResponse]> {
        let user = try req.auth.require(User.self)

        return Subscription.find(req.parameters.get("subscription_id"), on: req.db)
            .flatMapThrowing { (subscription: Subscription?) -> Subscription in
                guard let subscription = subscription, subscription.$user.id == user.id else {
                    throw ApiError(.channelNotFound)
                }
                return subscription
            }
            .flatMap { (subscription: Subscription) in
                Message.query(on: req.db)
                    .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
                    .filter(\Message.$createdAt, .greaterThanOrEqual, subscription.createdAt ?? Date.distantPast)
                    .sort(\.$createdAt, .descending)
                    .all()
                    .flatMapThrowing { messages in
                        try messages.map { message in
                            try MessageResponse(message, subscription: subscription)
                        }
                    }
            }
    }

    // TODO:
    func messagesForAllChannels(_ req: Request) throws -> EventLoopFuture<[MessageResponse]> {
        let user = try req.auth.require(User.self)

        return try Subscription.query(on: req.db)
            .filter(\Subscription.$user.$id == user.requireID())
            .sort(\.$createdAt, .descending)
            .all()
            .flatMap { (subscriptions: [Subscription]) in
                let messageResponses = subscriptions.map { subscription in
                    Message.query(on: req.db)
                        .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
                        .sort(\.$createdAt, .descending)
                        .all()
                        .flatMapThrowing { messages in
                            try messages.map { try MessageResponse($0, subscription: subscription) }
                        }
                }
                return req.eventLoop.flatten(messageResponses)
                    .map { responses in
                        responses
                            .flatMap { $0 }
                            .sorted(by: { $0.createdAt > $1.createdAt })
                    }
            }
    }

    private func saveAndNotify(_ req: Request, message: Message) -> EventLoopFuture<Message> {
        message.create(on: req.db)
            .flatMap { _ in req.push.notifyDevices(message: message) }
            .transform(to: message)
    }
}
