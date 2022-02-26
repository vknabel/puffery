import Fluent
import FluentPostgresDriver
import Queues
import QueuesRedisDriver
import SendGrid
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    app.passwords.use(.bcrypt)

    // Register providers first
    try app.databases.use(.postgres(
        url: URL(string:
            Environment.get("DATABASE_URL")
                ?? "postgres://puffery-test:puffery-test@localhost:5431/puffery-test"
        )!
    ), as: DatabaseID.psql)

    try app.queues.use(.redis(url: Environment.get("REDIS_URL") ?? "redis://localhost:6378"))

    if Environment.process.SENDGRID_API_KEY != nil {
        app.sendgrid.initialize() // SENDGRID_API_KEY
    } else {
        app.logger.warning("Missing SENDGRID_API_KEY. Deactivate emails.")
    }

    let emailJob = SendEmailJob()
    app.queues.add(emailJob)

    let statChannels: [String] = Environment.get("PUFFERY_STATISTICS_CHANNELS")?
        .split(separator: ",")
        .map(String.init)
        ?? []
    app.queues.schedule(ReportStatisticsJob(notifyKeys: statChannels))
        .daily()
        .at(.noon)
    app.queues.schedule(ReportStatisticsJob(notifyKeys: statChannels))
        .daily()
        .at(.midnight)

    // Register middleware
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    try migrate(app)
    try apns(app)
    try routes(app)

    if let inProcessJobs = Environment.get("PUFFERY_IN_PROCESS_JOBS")?.lowercased(),
       ["true", "yes", "1"].contains(inProcessJobs)
    {
        try app.queues.startInProcessJobs(on: .default)
    }
}
