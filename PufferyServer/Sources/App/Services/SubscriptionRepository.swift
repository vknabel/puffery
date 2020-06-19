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

    func find(_ id: UUID?, of user: User, where queries: (QueryBuilder<Subscription>) -> QueryBuilder<Subscription> = { $0 }) -> EventLoopFuture<Subscription> {
        guard let id = id else {
            return eventLoop.makeFailedFuture(ApiError(.channelNotFound))
        }
        return queries(Subscription.query(on: db).filter(\.$id == id))
            .first()
            .flatMapThrowing { (subscription: Subscription?) -> Subscription in
                guard let subscription = subscription, subscription.$user.id == user.id else {
                    throw ApiError(.channelNotFound)
                }
                return subscription
            }
    }
}
