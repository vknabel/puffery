import Fluent
import FluentSQL
import FluentPostgresDriver

struct _2020_04_26_UniqueSubscriptionMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        (database as! PostgresDatabase).sql().raw("""
        ALTER TABLE subscriptions
        ADD CONSTRAINT subscription_unique UNIQUE (user_id, channel_id);
        """).run()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        (database as! PostgresDatabase).sql().raw("""
            ALTER TABLE subscriptions
            DROP CONSTRAINT subscription_unique;
            """).run()
    }
}
