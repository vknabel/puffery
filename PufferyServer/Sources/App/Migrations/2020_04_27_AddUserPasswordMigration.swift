import Fluent

struct _2020_04_27_AddUserPasswordMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .field("password_hash", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .deleteField("password_hash")
            .update()
    }
}
