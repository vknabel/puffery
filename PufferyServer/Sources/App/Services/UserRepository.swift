import Fluent
import Vapor

extension Request {
    var users: UserRepository { UserRepository(req: self) }
}

struct UserRepository {
    let req: Request

    func sendLoginConfirmation(_ user: User) async throws {
        guard let emailAddress = user.email else {
            throw ApiError(.invalidCredentials)
        }

        let confirmation = try Confirmation(scope: "login", snapshot: nil, user: user)
        try await confirmation.create(on: req.db)
        let email = try Email(
            subject: "Log in to Puffery",
            email: emailAddress,
            contents: """
            Click on the sign-in link below:
            \(confirmation.url())
            """
        )
        try await req.queue.dispatch(SendEmailJob.self, email)
    }

    func confirmEmailIfNeeded(_ user: User) async throws {
        guard let emailAddress = user.email else {
            return
        }

        let confirmation = try Confirmation(scope: "email", snapshot: emailAddress, user: user)
        try await confirmation.create(on: req.db)
        let email = try Email(
            subject: "Confirm Puffery Account Email",
            email: emailAddress,
            contents: """
            To confirm your mail address, click on the link below:
            \(confirmation.url())
            """
        )

        try await req.queue.dispatch(SendEmailJob.self, email)
    }
}

extension Confirmation {
    func url() throws -> String {
        try "puffery://puffery.app/confirmations/\(scope)/\(requireID())"
    }
}
