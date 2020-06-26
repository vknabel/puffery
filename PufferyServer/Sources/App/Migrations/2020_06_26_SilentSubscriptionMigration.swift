import Fluent
import FluentPostgresDriver

struct _2020_06_26_SilentSubscriptionMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions")
            .field("is_silent", .bool, .sql(raw: "NOT NULL DEFAULT FALSE"))
            .field("updated_at", .datetime, .required)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subscriptions")
            .deleteField("is_silent")
            .deleteField("updated_at")
            .update()
    }
}
