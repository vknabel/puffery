import Fluent
import Vapor

final class Subscription: Model {
    static let schema = "subscriptions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User
    @Parent(key: "channel_id")
    var channel: Channel
    @Field(key: "can_notify")
    var canNotify: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, user: User, channel: Channel, canNotify: Bool) throws {
        self.id = id
        $user.value = user
        $channel.value = channel
        self.canNotify = canNotify
    }
}

/// Allows `Subscription` to be used as a dynamic migration.
struct CreateSubscriptionMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Subscription.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, "id"))
            .field("channel_id", .uuid, .references(Channel.schema, "id"))
            .field("can_notify", .bool)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Subscription.schema).delete()
    }
}
