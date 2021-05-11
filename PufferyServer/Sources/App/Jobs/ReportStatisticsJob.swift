import Queues
import SendGrid
import Vapor
import Fluent

struct Statistics {
    let messageCount: Int
    let channelCount: Int
    let userCount: Int
    let registeredUserCount: Int
}

struct ReportStatisticsJob: ScheduledJob {
    let notifyKeys: [String]
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func run(context: QueueContext) -> EventLoopFuture<Void> {
        let channels = context.channels.all(withNotifyKeys: notifyKeys)
        let today = formatter.string(from: Date())
        return channels.flatMap { channels in
            statistics(context, ignoring: channels).flatMap { stats in
                context.eventLoop.flatten(channels.map { channel in
                    context.messages.notify(
                        channel: channel,
                        title: "Puffery stats for \(today)",
                        body: """
                        There are \(stats.userCount) users, \(stats.registeredUserCount) provided an email.
                        They sent \(stats.messageCount) messages to \(stats.channelCount) channels.
                        """,
                        color: nil
                    )
                })
            }
        }
        .transform(to: ())
        .always { _ in
            context.logger.info("Sent Puffery stats", source: "ReportStatisticsJob")
        }
    }
    
    private func statistics(_ context: QueueContext, ignoring channels: [Channel]) -> EventLoopFuture<Statistics> {
        let statCounters = [
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
                .count()
        ]
        return EventLoopFuture.whenAllSucceed(statCounters, on: context.eventLoop)
            .map { counters in
                Statistics(
                    messageCount: counters[0],
                    channelCount: counters[1],
                    userCount: counters[2],
                    registeredUserCount: counters[3]
                )
            }
    }
}
