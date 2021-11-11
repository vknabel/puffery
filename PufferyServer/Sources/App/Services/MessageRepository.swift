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

    func latest(for subscription: Subscription) async throws -> [Message] {
        try await Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .sort(\.$createdAt, .descending)
            .limit(20)
            .all()
    }

    func count(for subscription: Subscription) async throws -> Int {
        try await Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .count()
    }

    func latestSubscribed(for subscriptions: [Subscription]) async throws -> [SubscriptionMessage] {
        let messageResponses = subscriptions.map { subscription in
            eventLoop.from(task: { try await self.latest(for: subscription) })
                .map { messages in
                    messages.map {
                        SubscriptionMessage(message: $0, subscription: subscription)
                    }
                }
        }
        return try await eventLoop.flatten(messageResponses)
            .map { responses in
                responses
                    .flatMap { $0 }
                    .sorted(by: >)
                    .prefix(30)
            }
            .map(Array.init(_:))
            .get()
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
