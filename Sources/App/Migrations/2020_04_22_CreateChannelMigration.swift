import Fluent

/// Allows `Channel` to be used as a dynamic migration.
struct CreateChannelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("channels")
            .id()
            .field("title", .string, .required)
            .field("notifyKey", .string, .required)
            .field("receiveOnlyKey", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("channels").delete()
    }
}
