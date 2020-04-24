import Fluent

/// Allows `Message` to be used as a dynamic migration.
struct CreateMessageMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("messages")
            .id()
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("color", .string)
            .field("created_at", .datetime, .required)
            .field("channel_id", .uuid, .references(Channel.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("messages").delete()
    }
}
