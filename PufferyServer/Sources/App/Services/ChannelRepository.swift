import Fluent
import Queues
import Vapor

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

    func find(byNotifyKey notifyKey: String) async throws -> Channel {
        let channel = try await Channel.query(on: db)
            .filter(\.$notifyKey, .equal, notifyKey.uppercased())
            .first()

        guard let channel = channel else {
            throw ApiError(.channelNotFound)
        }
        return channel
    }

    func find(byReceiveOrNotifyKey receiveOrNotifyKey: String) async throws -> Channel {
        let channel = try await Channel.query(on: db)
            .group(.or) { query in
                query.filter(\Channel.$notifyKey == receiveOrNotifyKey)
                    .filter(\Channel.$receiveOnlyKey == receiveOrNotifyKey)
            }
            .sort(\.$title)
            .first()

        guard let channel = channel else {
            throw ApiError(.channelNotFound)
        }
        return channel
    }

    func all(withNotifyKeys notifyKeys: [String]) async throws -> [Channel] {
        try await Channel.query(on: db)
            .filter(\Channel.$notifyKey ~~ notifyKeys.map { $0.uppercased() })
            .all()
    }

    func countSubscriptions(
        _ channelId: UUID?,
        of _: User,
        where queries: (QueryBuilder<Subscription>) -> QueryBuilder<Subscription> = { $0 }
    ) async throws -> Int {
        guard let channelId = channelId else {
            throw ApiError(.channelNotFound)
        }

        return try await queries(
            Subscription.query(on: db)
                .filter(\.$channel.$id == channelId)
        )
        .count()
    }
}
