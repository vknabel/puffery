import Fluent
import Vapor
import Queues

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

    func latest(for subscription: Subscription) -> EventLoopFuture<[Message]> {
        Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .sort(\.$createdAt, .descending)
            .limit(20)
            .all()
    }
    
    func count(for subscription: Subscription) -> EventLoopFuture<Int> {
        Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .count()
    }

    func latestSubscribed(for subscriptions: [Subscription]) -> EventLoopFuture<[SubscriptionMessage]> {
        let messageResponses = subscriptions.map { subscription in
            self.latest(for: subscription)
                .map { messages in
                    messages.map {
                        SubscriptionMessage(message: $0, subscription: subscription)
                    }
                }
        }
        return eventLoop.flatten(messageResponses)
            .map { responses in
                responses
                    .flatMap { $0 }
                    .sorted(by: >)
                    .prefix(30)
            }
            .map(Array.init(_:))
    }
    
    func notify(channel: Channel, title: String, body: String, color: String?) -> EventLoopFuture<Message> {
        do {
            let message = try Message(
                channel: channel,
                title: title,
                body: body,
                color: color
            )
            return message.create(on: db)
                .flatMap { _ in push.notifyDevices(message: message) }
                .transform(to: message)
        } catch {
            return eventLoop.future(error: error)
        }
    }
}
