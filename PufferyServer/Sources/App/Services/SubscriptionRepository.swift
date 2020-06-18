import Fluent
import Vapor

extension Request {
    var subscriptions: SubscriptionRepository {
        SubscriptionRepository(eventLoop: eventLoop, db: db)
    }
}

struct SubscriptionRepository {
    let eventLoop: EventLoop
    let db: Database

    func all(of user: User) -> EventLoopFuture<[Subscription]> {
        do {
            return try Subscription.query(on: db)
                .filter(\Subscription.$user.$id == user.requireID())
                .sort(\.$createdAt, .descending)
                .all()
        } catch {
            return eventLoop.future(error: error)
        }
    }

    func find(_ id: UUID?, of user: User) -> EventLoopFuture<Subscription> {
        Subscription.find(id, on: db)
            .flatMapThrowing { (subscription: Subscription?) -> Subscription in
                guard let subscription = subscription, subscription.$user.id == user.id else {
                    throw ApiError(.channelNotFound)
                }
                return subscription
            }
    }
}
