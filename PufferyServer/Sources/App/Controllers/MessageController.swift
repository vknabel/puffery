import APIDefinition
import APNS
import Fluent
import Vapor

struct InboundEmail: Codable, Content {
    var envelope: Envelope
    var subject: String
    var text: String

    struct Envelope: Codable {
        var from: String
        var to: [String]
    }
}

final class MessageController {
    func create(_ req: Request) throws -> EventLoopFuture<MessageResponse> {
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
            return self.saveAndNotify(req, message: message)
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

    func publicEmail(_ req: Request) throws -> EventLoopFuture<NotifyMessageResponse> {
        let inboundEmail = try req.content.decode(InboundEmail.self)
        let notifyKey = String(inboundEmail.envelope.to.first?.prefix(while: { $0 != "@" }) ?? "")
        return Channel.query(on: req.db)
            .filter(\.$notifyKey, .equal, notifyKey)
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError(.channelNotFound)
                }
                return channel
            }
            .flatMapThrowing { channel in
                try Message(
                    channel: channel,
                    title: inboundEmail.subject,
                    body: inboundEmail.text,
                    color: nil
                )
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
                req.messages.latest(for: subscription)
                    .flatMapThrowing { messages in
                        try messages.map { message in
                            try MessageResponse(message, subscription: subscription)
                        }
                    }
            }
    }

    func messagesForAllChannels(_ req: Request) throws -> EventLoopFuture<[MessageResponse]> {
        let user = try req.auth.require(User.self)

        return req.subscriptions.all(of: user)
            .flatMap(req.messages.latestSubscribed(for:))
            .flatMapThrowing { messages in
                try messages.map {
                    try MessageResponse($0.message, subscription: $0.subscription)
                }
            }
    }

    private func saveAndNotify(_ req: Request, message: Message) -> EventLoopFuture<Message> {
        message.create(on: req.db)
            .flatMap { _ in req.push.notifyDevices(message: message) }
            .transform(to: message)
    }
}
