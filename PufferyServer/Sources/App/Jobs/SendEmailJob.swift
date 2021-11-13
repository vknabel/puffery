import Queues
import SendGrid
import Vapor

struct Email: Codable {
    var subject: String
    var email: String
    var contents: String
}

struct SendEmailJob: AsyncJob {
    typealias Payload = Email

    func dequeue(_ context: QueueContext, _ payload: Email) async throws {
        let sendingEmailAddress = "noreply@puffery.app"
        let email = SendGridEmail(
            personalizations: [Personalization(to: [EmailAddress(email: payload.email)])],
            from: EmailAddress(email: sendingEmailAddress, name: nil),
            subject: payload.subject,
            content: [
                ["type": "text/plain", "value": payload.contents],
            ]
        )

        defer { context.logger.info("Sent E-Mail", metadata: ["subject": .string(payload.subject)], source: "SendEmailJob") }
        return try await context.application.sendgrid.client.send(
            email: email,
            on: context.eventLoop
        ).get()
    }
}
