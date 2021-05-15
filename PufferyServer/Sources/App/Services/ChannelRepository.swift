import Fluent
import Vapor
import Queues

extension Request {
    var channels: ChannelRepository {
        ChannelRepository(eventLoop: eventLoop, db: db)
    }
}

extension QueueContext {
    var channels: ChannelRepository {
        ChannelRepository(eventLoop: eventLoop, db: application.db)
    }
}

struct ChannelRepository {
    let eventLoop: EventLoop
    let db: Database

    func find(byNotifyKey notifyKey: String) -> EventLoopFuture<Channel> {
        return Channel.query(on: db)
            .filter(\.$notifyKey, .equal, notifyKey.uppercased())
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError(.channelNotFound)
                }
                return channel
            }
    }

    func find(byReceiveOrNotifyKey receiveOrNotifyKey: String) -> EventLoopFuture<Channel> {
        return Channel.query(on: db)
            .group(.or) { query in
                query.filter(\Channel.$notifyKey == receiveOrNotifyKey)
                    .filter(\Channel.$receiveOnlyKey == receiveOrNotifyKey)
            }
            .sort(\.$title)
            .first()
            .flatMapThrowing { (channel) throws -> Channel in
                guard let channel = channel else {
                    throw ApiError(.channelNotFound)
                }
                return channel
            }
    }

    func all(withNotifyKeys notifyKeys: [String]) -> EventLoopFuture<[Channel]> {
        return Channel.query(on: db)
            .filter(\Channel.$notifyKey ~~ notifyKeys.map { $0.uppercased() })
            .all()
    }

    func countSubscriptions(_ channelId: UUID?, of user: User, where queries: (QueryBuilder<Subscription>) -> QueryBuilder<Subscription> = { $0 }) -> EventLoopFuture<Int> {
        guard let channelId = channelId else {
            return eventLoop.makeFailedFuture(ApiError(.channelNotFound))
        }
        
        return queries(
            Subscription.query(on: db)
                .filter(\.$channel.$id == channelId)
            )
            .count()
    }
}
