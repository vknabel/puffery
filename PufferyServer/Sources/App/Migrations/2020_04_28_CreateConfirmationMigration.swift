import Fluent
import FluentPostgresDriver

struct _2020_04_28_CreateConfirmationMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("confirmations")
            .id()
            .field("scope", .string, .required)
            .field("snapshot", .string)
            .field("user_id", .uuid, .required)
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .field("expires_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("confirmations").delete()
    }
}
