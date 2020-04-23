import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Register providers first
    try app.databases.use(.postgres(
        url: URL(string: Environment.get("DATABASE_URL") ?? "postgres://vapor_username:vapor_password@localhost:5432/vapor_database")!
    ), as: DatabaseID.psql)

    // Register middleware
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    // Configure migrations
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateChannelMigration())
    app.migrations.add(CreateDeviceMigration())
    app.migrations.add(CreateMessageMigration())
    app.migrations.add(CreateSubscriptionMigration())
    app.migrations.add(CreateUserTokenMigration())

    app.migrations.add(MakeEmailsOptionalUserMigration2020_04_23())

    try apns(app)
    try routes(app)
}
