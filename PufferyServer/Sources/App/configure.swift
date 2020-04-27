import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    app.passwords.use(.bcrypt)

    // Register providers first
    try app.databases.use(.postgres(
        url: URL(string: Environment.get("DATABASE_URL") ?? "postgres://vapor_username:vapor_password@localhost:5432/vapor_database")!
    ), as: DatabaseID.psql)

    // Register middleware
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    try migrate(app)
    try apns(app)
    try routes(app)
}
