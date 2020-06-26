import Fluent
import FluentPostgresDriver
import FluentSQL

struct _2020_04_27_UniqueUserEmailsAndDeletionRulesMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.transaction { database in
            let sql = database as! SQLDatabase
            let migrations: [SQLQueryString] = [
                """
                ALTER TABLE users
                ADD CONSTRAINT email_unique UNIQUE (email);
                """,

                """
                ALTER TABLE user_tokens
                DROP CONSTRAINT user_tokens_user_id_fkey,
                ADD CONSTRAINT user_tokens_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE;
                """,

                """
                ALTER TABLE subscriptions
                DROP CONSTRAINT subscriptions_user_id_fkey,
                ADD CONSTRAINT subscriptions_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE;
                """,

                """
                ALTER TABLE devices
                DROP CONSTRAINT devices_user_id_fkey,
                ADD CONSTRAINT devices_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE;
                """,
            ]
            return database.eventLoop.flatten(migrations.map { sql.raw($0) }.map { $0.run() })
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.transaction { database in
            let sql = database as! SQLDatabase
            let migrations: [SQLQueryString] = [
                """
                ALTER TABLE users
                DROP CONSTRAINT email_unique;
                """,

                """
                ALTER TABLE user_tokens
                DROP CONSTRAINT user_tokens_user_id_fkey,
                ADD CONSTRAINT user_tokens_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id);
                """,

                """
                ALTER TABLE subscriptions
                DROP CONSTRAINT subscriptions_user_id_fkey,
                ADD CONSTRAINT subscriptions_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id);
                """,

                """
                ALTER TABLE devices
                DROP CONSTRAINT devices_user_id_fkey,
                ADD CONSTRAINT devices_user_id_fkey
                    FOREIGN KEY (user_id)
                    REFERENCES users(id);
                """,
            ]
            return database.eventLoop.flatten(migrations.map { sql.raw($0) }.map { $0.run() })
        }
    }
}
