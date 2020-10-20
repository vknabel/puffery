import Queues
import SendGrid
import Vapor

struct Email: Codable {
    var subject: String
    var email: String
    var contents: String
}

struct SendEmailJob: Job {
    typealias Payload = Email

    func dequeue(_ context: QueueContext, _ payload: Email) -> EventLoopFuture<Void> {
        let sendingEmailAddress = "noreply@puffery.app"
        let email = SendGridEmail(
            personalizations: [Personalization(to: [EmailAddress(email: payload.email)])],
            from: EmailAddress(email: sendingEmailAddress, name: nil),
            subject: payload.subject,
            content: [
                ["type": "text/plain", "value": payload.contents],
            ]
        )

        return context.eventLoop.tryFuture {
            try context.application.sendgrid.client.send(
                email: email,
                on: context.eventLoop
            )
        }
        .flatMap { $0 }
        .always { _ in
            context.logger.info("Sent E-Mail", metadata: ["subject": .string(payload.subject)], source: "SendEmailJob")
        }
    }
}
