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
    func create(_ req: Request) async throws -> MessageResponse {
        let user = try req.auth.require(User.self)
        let createMessage = try req.content.decode(CreateMessageRequest.self)

        let subscription = try await Subscription.find(
            req.parameters.get("subscription_id"),
            on: req.db,
            with: \.$channel
        )

        guard let subscription = subscription, user.id == subscription.$user.id else {
            throw ApiError(.channelNotFound)
        }
        let message = try await req.messages.notify(
            channel: subscription.channel,
            title: createMessage.title,
            body: createMessage.body,
            color: createMessage.color
        )
        return try MessageResponse(message, subscription: subscription)
    }

    func publicNotify(_ req: Request) async throws -> NotifyMessageResponse {
        let notifyKey = req.parameters.get("notify_key")
        let createMessage = try req.content.decode(CreateMessageRequest.self)
        let channel = try await req.channels.find(byNotifyKey: notifyKey ?? "")
        let message = try await req.messages.notify(
            channel: channel,
            title: createMessage.title,
            body: createMessage.body,
            color: createMessage.color
        )
        return try NotifyMessageResponse(message)
    }

    func publicEmail(_ req: Request) async throws -> NotifyMessageResponse {
        let inboundEmail = try req.content.decode(InboundEmail.self)
        let notifyKey = String(inboundEmail.envelope.to.first?.prefix(while: { $0 != "@" }) ?? "")
        let channel = try await req.channels.find(byNotifyKey: notifyKey)
        let message = try await req.messages.notify(
            channel: channel,
            title: inboundEmail.subject,
            body: inboundEmail.text,
            color: nil
        )
        return try NotifyMessageResponse(message)
    }

    func index(_ req: Request) async throws -> [MessageResponse] {
        let user = try req.auth.require(User.self)

        let subscription = try await Subscription.find(req.parameters.get("subscription_id"), on: req.db)
        guard let subscription = subscription, subscription.$user.id == user.id else {
            throw ApiError(.channelNotFound)
        }

        let messages = try await req.messages.latest(for: subscription)
        return try messages.map { message in
            try MessageResponse(message, subscription: subscription)
        }
    }

    func messagesForAllChannels(_ req: Request) async throws -> [MessageResponse] {
        let user = try req.auth.require(User.self)

        let subs = try await req.subscriptions.all(of: user)
        let messages = try await req.messages.latestSubscribed(for: subs)
        return try messages.map {
            try MessageResponse($0.message, subscription: $0.subscription)
        }
    }
}
