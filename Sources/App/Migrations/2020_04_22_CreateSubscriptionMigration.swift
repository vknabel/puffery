import Fluent

/// Allows `Subscription` to be used as a dynamic migration.
struct CreateSubscriptionMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions")
            .id()
            .field("user_id", .uuid, .references(User.schema, "id"))
            .field("channel_id", .uuid, .references(Channel.schema, "id"))
            .field("can_notify", .bool)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions").delete()
    }
}
