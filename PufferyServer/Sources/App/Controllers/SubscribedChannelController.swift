import Fluent
import Vapor
import APIDefinition

final class SubscribedChannelController {
    func create(_ req: Request) throws -> Future<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let createChannel = try req.content.decode(CreateChannelRequest.self)
        let channel = Channel(title: createChannel.title)
        return channel
            .create(on: req.db)
            .flatMap { _ in
                let subscription = try Subscription(user: user, channel: channel, canNotify: true)
                return subscription.create(on: req.db)
                    .transform(to: subscription)
            }
            .flatMapThrowing { subscription in
                try SubscribedChannelResponse(subscription: subscription)
            }
    }

    func index(_ req: Request) throws -> Future<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func indexShared(_ req: Request) throws -> Future<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == false)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func indexOwn(_ req: Request) throws -> Future<[SubscribedChannelResponse]> {
        let user = try req.auth.require(User.self)

        return user.$subscriptions.query(on: req.db)
            .filter(\Subscription.$canNotify == true)
            .with(\.$channel)
            .sort(\Subscription.$createdAt, .descending)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func subscribe(_ req: Request) throws -> Future<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let createSubscription = try req.content.decode(CreateSubscriptionRequest.self)

        let loadChannel = Channel.query(on: req.db)
            .group(.or) { query in
                query.filter(\Channel.$notifyKey == createSubscription.receiveOrNotifyKey)
                    .filter(\Channel.$receiveOnlyKey == createSubscription.receiveOrNotifyKey)
            }
            .sort(\.$title)
            .first()

        return loadChannel.flatMap { channel in
            if let channel = channel {
                let subscription = try Subscription(
                    user: user,
                    channel: channel,
                    canNotify: channel.notifyKey == createSubscription.receiveOrNotifyKey
                )
                return subscription.create(on: req.db).flatMapThrowing { _ in
                    try SubscribedChannelResponse(subscription: subscription)
                }
            } else {
                return req.eventLoop.future(error: ApiError(.channelNotFound))
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
            notifyKey: subscription.canNotify ? subscription.channel.notifyKey : nil
        )
    }
}
