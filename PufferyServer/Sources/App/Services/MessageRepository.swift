import Fluent
import Vapor

extension Request {
    var messages: MessageRepository {
        MessageRepository(eventLoop: eventLoop, db: db)
    }
}

struct MessageRepository {
    let eventLoop: EventLoop
    let db: Database

    func latest(for subscription: Subscription) -> EventLoopFuture<[Message]> {
        Message.query(on: db)
            .filter(\Message.$channel.$id, .equal, subscription.$channel.id)
            .filter(\Message.$createdAt, .greaterThanOrEqual, subscription.createdAt ?? Date.distantPast)
            .sort(\.$createdAt, .descending)
            .limit(20)
            .all()
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
}
