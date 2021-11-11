import Fluent
import Queues
import SendGrid
import Vapor

struct Statistics {
    let messageCount: Int
    let channelCount: Int
    let userCount: Int
    let registeredUserCount: Int
}

struct ReportStatisticsJob: AsyncScheduledJob {
    let notifyKeys: [String]
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func run(context: QueueContext) async throws {
        let channels = try await context.channels.all(withNotifyKeys: notifyKeys)
        let today = formatter.string(from: Date())
        defer { context.logger.info("Sent Puffery stats", source: "ReportStatisticsJob") }

        let stats = try await statistics(context, ignoring: channels)

        for channel in channels {
            _ = try? await context.messages.notify(
                channel: channel,
                title: "Puffery stats for \(today)",
                body: """
                There are \(stats.userCount) users, \(stats.registeredUserCount) provided an email.
                They sent \(stats.messageCount) messages to \(stats.channelCount) channels.
                """,
                color: nil
            )
        }
    }

    private func statistics(_ context: QueueContext, ignoring channels: [Channel]) async throws -> Statistics {
        let counters = try await [
            context.application.db.query(Message.self)
                .filter(\.$channel.$id !~ channels.compactMap(\.id))
                .count(),
            context.application.db.query(Channel.self)
                .filter(\.$id !~ channels.compactMap(\.id))
                .count(),
            context.application.db.query(User.self)
                .count(),
            context.application.db.query(User.self)
                .filter(\.$email, .notEqual, nil)
                .count(),
        ]
        return Statistics(
            messageCount: counters[0],
            channelCount: counters[1],
            userCount: counters[2],
            registeredUserCount: counters[3]
        )
    }
}
