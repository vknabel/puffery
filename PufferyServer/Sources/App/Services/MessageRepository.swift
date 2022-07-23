import Fluent
import Queues
import Vapor

extension Request {
    var messages: MessageRepository {
        MessageRepository(eventLoop: eventLoop, push: push, db: db)
    }
}

extension QueueContext {
    var messages: MessageRepository {
        MessageRepository(eventLoop: eventLoop, push: push, db: application.db)
    }
}

struct MessageRepository {
    let eventLoop: EventLoop
    let push: PushService
    let db: Database

    func latest(for subscription: Subscription, page: PageRequest) async throws -> [Message] {
        try await Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .sort(\.$createdAt, .descending)
            .paginate(page)
            .items
    }

    func count(for subscription: Subscription) async throws -> Int {
        try await Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .count()
    }

    func latestSubscribed(for subscriptions: [Subscription], page: PageRequest) async throws -> [SubscriptionMessage] {
        let messages = try await Message.query(on: db)
            .filter(\Message.$channel.$id ~~ subscriptions.map(\.$channel.id))
            .sort(\.$createdAt, .descending)
            .join(Channel.self, on: \Message.$channel.$id == \Channel.$id)
            .join(Subscription.self, on: \Channel.$id == \Subscription.$channel.$id)
            .paginate(page)

        return try messages.items.map { message in
            try SubscriptionMessage(
                message: message,
                subscription: message.joined(Subscription.self)
            )
        }
    }

    func notify(channel: Channel, title: String, body: String, color: String?) async throws -> Message {
        let message = try Message(
            channel: channel,
            title: title,
            body: body,
            color: color
        )
        try await message.create(on: db)
        try await push.notifyDevices(message: message)
        return message
    }
}
