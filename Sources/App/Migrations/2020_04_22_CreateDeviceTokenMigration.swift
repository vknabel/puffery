import Fluent

/// Allows `DeviceToken` to be used as a dynamic migration.
struct CreateDeviceMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("devices")
            .id()
            .field("token", .string, .required)
            .field("is_production", .bool, .required)
            .field("user_id", .uuid, .references(User.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("devices").delete()
    }
}
