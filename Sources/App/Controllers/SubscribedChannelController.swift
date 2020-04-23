import Vapor

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
//            .join(Channel.self, on: \Channel.$id == \Subscription.$channel.$id)
            .with(\.$channel)
//            .alsoDecode(Channel.self)
            .all()
            .flatMapThrowing { try $0.map(SubscribedChannelResponse.init) }
    }

    func subscribe(_ req: Request) throws -> Future<SubscribedChannelResponse> {
        let user = try req.auth.require(User.self)
        let createSubscription = try req.content.decode(CreateSubscriptionRequest.self)
        let canNotify: Bool
        let loadChannel: Future<Channel?>

        switch createSubscription {
        case let .notifyKey(key):
            canNotify = true
            loadChannel = Channel.query(on: req.db)
                .filter(\.$notifyKey, .equal, key)
                .first()
        case let .receiveOnlyKey(key):
            canNotify = false
            loadChannel = Channel.query(on: req.db)
                .filter(\.$receiveOnlyKey, .equal, key)
                .first()
        }
        return loadChannel.flatMap { channel in
            if let channel = channel {
                let subscription = try Subscription(
                    user: user,
                    channel: channel,
                    canNotify: canNotify
                )
                let subscribedChannel = try SubscribedChannelResponse(subscription: subscription)
                return subscription.save(on: req.db).transform(to: subscribedChannel)
            } else {
                return req.eventLoop.future(error: ApiError.channelNotFound)
            }
        }
    }
}

struct CreateChannelRequest: Content {
    var title: String
}

struct SubscribedChannelResponse: Content {
    /// Actually the ID of the Subscription!
    var id: UUID
    var title: String
    var receiveOnlyKey: String
    var notifyKey: String?
}

extension SubscribedChannelResponse {
    init(subscription: Subscription) throws {
        id = try subscription.requireID()
        title = subscription.channel.title
        receiveOnlyKey = subscription.channel.receiveOnlyKey
        notifyKey = subscription.canNotify ? subscription.channel.notifyKey : nil
    }
}

enum CreateSubscriptionRequest: Content {
    case notifyKey(String)
    case receiveOnlyKey(String)

    init(from decoder: Decoder) throws {
        if let notify = try? CreateNotifySubscription(from: decoder) {
            self = .notifyKey(notify.notifyKey)
        } else {
            let receiveOnly = try CreateSubscribeOnlySubscription(from: decoder)
            self = .receiveOnlyKey(receiveOnly.receiveOnlyKey)
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .notifyKey(key):
            try CreateNotifySubscription(notifyKey: key).encode(to: encoder)
        case let .receiveOnlyKey(key):
            try CreateSubscribeOnlySubscription(receiveOnlyKey: key).encode(to: encoder)
        }
    }

    private struct CreateNotifySubscription: Codable {
        var notifyKey: String
    }

    private struct CreateSubscribeOnlySubscription: Codable {
        var receiveOnlyKey: String
    }
}
