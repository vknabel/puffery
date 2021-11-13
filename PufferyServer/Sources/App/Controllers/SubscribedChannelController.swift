import APIDefinition
import Fluent
import FluentSQL
import Vapor

final class SubscribedChannelController {
    func details(_ req: Request) async throws -> SubscribedChannelResponse {
        let user = try req.auth.require(User.self)
        let subscription = try await req.subscriptions.find(
            req.parameters.get("subscription_id"),
            of: user,
            where: { $0.with(\.$channel) }
        )
        return try SubscribedChannelResponse(subscription: subscription)
    }

    func statistics(_ req: Request) async throws -> SubscribedChannelStatisticsResponse {
        let user = try req.auth.require(User.self)
        let subscriptionId = try req.parameters.require("subscription_id", as: UUID.self)
        let subscription = try await req.subscriptions.find(subscriptionId, of: user)

        async let notifiers = req.channels.countSubscriptions(
            subscription.$channel.id,
            of: user,
            where: { $0.filter(\Subscription.$canNotify == true) }
        )
        async let receivers = req.channels.countSubscriptions(
            subscription.$channel.id,
            of: user,
            where: { $0.filter(\Subscription.$canNotify == false) }
        )
        async let messages = req.messages.count(for: subscription)

        return try await SubscribedChannelStatisticsResponse(
            notifiers: notifiers,
            receivers: receivers,
            messages: messages
        )
    }

    func create(_ req: Request) async throws -> SubscribedChannelResponse {
        let user = try req.auth.require(User.self)
        let createChannel = try req.content.decode(CreateChannelRequest.self)
        let channel = Channel(title: createChannel.title)
        try await channel.create(on: req.db)
        let subscription = try Subscription(user: user, channel: channel, canNotify: true, isSilent: createChannel.isSilent)
        try await subscription.create(on: req.db)
        return try SubscribedChannelResponse(subscription: subscription)
    }

    func update(_ req: Request) async throws -> SubscribedChannelResponse {
        let user = try req.auth.require(User.self)
        let updateSubscription = try req.content.decode(UpdateSubscriptionRequest.self)
        let subscription = try await req.subscriptions.find(
            req.parameters.get("subscription_id"),
            of: user,
            where: { $0.with(\.$channel) }
        )

        subscription.isSilent = updateSubscription.isSilent
        try await subscription.save(on: req.db)
        return try SubscribedChannelResponse(subscription: subscription)
    }

    func unsubscribe(_ req: Request) async throws -> SubscribedChannelDeletedResponse {
        let user = try req.auth.require(User.self)
        let subscription = try await req.subscriptions.find(
            req.parameters.get("subscription_id"),
            of: user
        )
        try await subscription.delete(force: true, on: req.db)
        return SubscribedChannelDeletedResponse()
    }

    func index(_ req: Request) async throws -> [SubscribedChannelResponse] {
        let user = try req.auth.require(User.self)

        let subscriptions = try await user.$subscriptions.query(on: req.db)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
        return try subscriptions.map(SubscribedChannelResponse.init)
    }

    func indexShared(_ req: Request) async throws -> [SubscribedChannelResponse] {
        let user = try req.auth.require(User.self)

        let subscriptions = try await user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == false)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
        return try subscriptions.map(SubscribedChannelResponse.init)
    }

    func indexOwn(_ req: Request) async throws -> [SubscribedChannelResponse] {
        let user = try req.auth.require(User.self)

        let subscriptions = try await user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == true)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
        return try subscriptions.map(SubscribedChannelResponse.init)
    }

    func subscribe(_ req: Request) async throws -> SubscribedChannelResponse {
        let user = try req.auth.require(User.self)
        let createSubscription = try req.content.decode(CreateSubscriptionRequest.self)

        let channel = try await req.channels.find(byReceiveOrNotifyKey: createSubscription.receiveOrNotifyKey)

        let subscription = try Subscription(
            user: user,
            channel: channel,
            canNotify: channel.notifyKey == createSubscription.receiveOrNotifyKey,
            isSilent: createSubscription.isSilent
        )
        try await subscription.create(on: req.db)
        return try SubscribedChannelResponse(subscription: subscription)
    }
}

extension SubscribedChannelResponse {
    init(subscription: Subscription) throws {
        self.init(
            id: try subscription.requireID(),
            title: subscription.channel.title,
            receiveOnlyKey: subscription.channel.receiveOnlyKey,
            notifyKey: subscription.canNotify ? subscription.channel.notifyKey : nil,
            isSilent: subscription.isSilent
        )
    }
}
