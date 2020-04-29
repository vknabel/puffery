import Fluent
import FluentPostgresDriver

struct _2020_04_28_ReplaceUserPasswordWithVerifiedFlagMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .deleteField("password_hash")
            .field("is_confirmed", .bool, .required)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .field("password_hash", .string)
            .deleteField("is_confirmed")
            .update()
    }
}
