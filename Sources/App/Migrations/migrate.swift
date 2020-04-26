import Vapor

func migrate(_ app: Application) throws {
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateChannelMigration())
    app.migrations.add(CreateDeviceMigration())
    app.migrations.add(CreateMessageMigration())
    app.migrations.add(CreateSubscriptionMigration())
    app.migrations.add(CreateUserTokenMigration())

    app.migrations.add(_2020_04_23_UniqueEmailsOptionalUserMigration())
    app.migrations.add(_2020_04_26_UniqueSubscriptionMigration())
}
