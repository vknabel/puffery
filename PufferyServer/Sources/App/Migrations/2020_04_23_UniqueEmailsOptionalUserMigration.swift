import Fluent

struct _2020_04_23_UniqueEmailsOptionalUserMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .updateField(.custom("email DROP NOT NULL"))
            .unique(on: "email")
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .updateField(.custom("email SET NOT NULL"))
            .unique()
            .update()
    }
}
