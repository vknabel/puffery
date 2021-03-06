import APIDefinition
import Fluent
import FluentSQL
import Vapor

final class SubscribedChannelController {
    func details(_ req: Request) throws -> EventLoopFuture<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        return req.subscriptions.find(req.parameters.get("subscription_id"), of: user, where: { $0.with(\.$channel) })
            .flatMapThrowing { subscription in
                try SubscribedChannelResponse(subscription: subscription)
            }
    }

    func statistics(_ req: Request) throws -> EventLoopFuture<SubscribedChannelStatisticsResponse> {
        let user = try req.auth.require(User.self)
        let subscriptionId = try req.parameters.require("subscription_id", as: UUID.self)
        return req.subscriptions.find(subscriptionId, of: user)
            .flatMap { subscription in
                EventLoopFuture.zip(
                    req.channels.countSubscriptions(subscription.$channel.id, of: user, where: { $0.filter(\Subscription.$canNotify == true) }),
                    req.channels.countSubscriptions(subscription.$channel.id, of: user, where: { $0.filter(\Subscription.$canNotify == false) }),
                    req.messages.count(for: subscription)
                ).map { (notifiers, receivers, messages) in
                        SubscribedChannelStatisticsResponse(
                            notifiers: notifiers,
                            receivers: receivers,
                            messages: messages
                        )
                    }
            }
    }

    func create(_ req: Request) throws -> EventLoopFuture<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let createChannel = try req.content.decode(CreateChannelRequest.self)
        let channel = Channel(title: createChannel.title)
        return channel
            .create(on: req.db)
            .flatMapThrowing { _ in try Subscription(user: user, channel: channel, canNotify: true, isSilent: createChannel.isSilent) }
            .flatMap { subscription in
                subscription.create(on: req.db).transform(to: subscription)
            }
            .flatMapThrowing { subscription in
                try SubscribedChannelResponse(subscription: subscription)
            }
    }

    func update(_ req: Request) throws -> EventLoopFuture<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let updateSubscription = try req.content.decode(UpdateSubscriptionRequest.self)
        return req.subscriptions.find(req.parameters.get("subscription_id"), of: user, where: { $0.with(\.$channel) })
            .flatMap { subscription in
                subscription.isSilent = updateSubscription.isSilent
                return subscription.save(on: req.db).transform(to: subscription)
            }
            .flatMapThrowing { subscription in
                try SubscribedChannelResponse(subscription: subscription)
            }
    }

    func unsubscribe(_ req: Request) throws -> EventLoopFuture<SubscribedChannelDeletedResponse> {
        let user = try req.auth.require(User.self)
        return req.subscriptions.find(req.parameters.get("subscription_id"), of: user)
            .flatMap { subscription in
                subscription.delete(force: true, on: req.db)
            }
            .transform(to: SubscribedChannelDeletedResponse())
    }

    func index(_ req: Request) throws -> EventLoopFuture<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func indexShared(_ req: Request) throws -> EventLoopFuture<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == false)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func indexOwn(_ req: Request) throws -> EventLoopFuture<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == true)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func subscribe(_ req: Request) throws -> EventLoopFuture<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let createSubscription = try req.content.decode(CreateSubscriptionRequest.self)

        return req.channels.find(byReceiveOrNotifyKey: createSubscription.receiveOrNotifyKey)
            .flatMap { channel in
                let subscription = try Subscription(
                    user: user,
                    channel: channel,
                    canNotify: channel.notifyKey == createSubscription.receiveOrNotifyKey,
                    isSilent: createSubscription.isSilent
                )
                return subscription.create(on: req.db).flatMapThrowing { _ in
                    try SubscribedChannelResponse(subscription: subscription)
                }
            }
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
