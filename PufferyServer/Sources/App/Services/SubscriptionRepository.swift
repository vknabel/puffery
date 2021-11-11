import Fluent
import FluentSQL
import Vapor

extension Request {
    var subscriptions: SubscriptionRepository {
        SubscriptionRepository(eventLoop: eventLoop, db: db)
    }
}

struct SubscriptionRepository {
    let eventLoop: EventLoop
    let db: Database

    func all(of user: User) async throws -> [Subscription] {
        try await Subscription.query(on: db)
            .filter(\Subscription.$user.$id == user.requireID())
            .sort(\.$createdAt, .descending)
            .all()
    }

    func find(_ id: UUID?, of user: User, where queries: (QueryBuilder<Subscription>) -> QueryBuilder<Subscription> = { $0 }) async throws -> Subscription {
        guard let id = id else {
            throw ApiError(.channelNotFound)
        }
        let subscription = try await queries(Subscription.query(on: db).filter(\.$id == id))
            .first()
        guard let subscription = subscription, subscription.$user.id == user.id else {
            throw ApiError(.channelNotFound)
        }
        return subscription
    }
}
