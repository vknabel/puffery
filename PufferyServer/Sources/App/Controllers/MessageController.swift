import APIDefinition
import APNS
import Fluent
import Vapor

struct InboundEmail: Codable, Content {
    var envelope: Envelope
    var subject: String
    var text: String

    init(envelope: Envelope, subject: String, text: String) {
        self.envelope = envelope
        self.subject = subject
        self.text = text
    }

    struct Envelope: Codable {
        var from: String
        var to: [String]

        init(from: String, to: [String]) {
            self.from = from
            self.to = to
        }
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
            return req.messages.notify(
                channel: subscription.channel,
                title: createMessage.title,
                body: createMessage.body,
                color: createMessage.color
            ).flatMapThrowing { message in
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
            .flatMap { channel in
                req.messages.notify(
                    channel: channel,
                    title: createMessage.title,
                    body: createMessage.body,
                    color: createMessage.color
                )
            }
            .flatMapThrowing { message in try NotifyMessageResponse(message) }
    }

    func publicEmail(_ req: Request) throws -> EventLoopFuture<NotifyMessageResponse> {
        let inboundEmail = try req.content.decode(InboundEmail.self)
        let notifyKey = String(inboundEmail.envelope.to.first?.prefix(while: { $0 != "@" }) ?? "")
        return Channel.query(on: req.db)
            .filter(\.$notifyKey, .equal, notifyKey.uppercased())
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError(.channelNotFound)
                }
                return channel
            }
            .flatMap { channel in
                req.messages.notify(
                    channel: channel,
                    title: inboundEmail.subject,
                    body: inboundEmail.text,
                    color: nil
                )
            }
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
}
