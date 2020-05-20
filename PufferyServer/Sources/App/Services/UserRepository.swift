import Fluent
import Vapor

extension Request {
    var users: UserRepository { UserRepository(req: self) }
}

struct UserRepository {
    let req: Request

    func sendLoginConfirmation(_ user: User) -> EventLoopFuture<Void> {
        guard let emailAddress = user.email else {
            return req.eventLoop.future(error: ApiError(.invalidCredentials))
        }
        do {
            let confirmation = try Confirmation(scope: "login", snapshot: nil, user: user)
            return confirmation.create(on: req.db)
                .flatMapThrowing { _ in
                    try Email(
                        subject: "Log in to Puffery",
                        email: emailAddress,
                        contents: "Push the button: \(confirmation.url())"
                    )
                }
                .flatMap { email in
                    self.req.queue.dispatch(SendEmailJob.self, email)
                }
        } catch {
            return req.eventLoop.future(error: error)
        }
    }

    func confirmEmailIfNeeded(_ user: User) -> EventLoopFuture<Void> {
        guard let emailAddress = user.email else {
            return req.eventLoop.future()
        }
        do {
            let confirmation = try Confirmation(scope: "email", snapshot: emailAddress, user: user)
            return confirmation.create(on: req.db)
                .flatMapThrowing { _ in
                    try Email(
                        subject: "Confirm Puffery Account Email",
                        email: emailAddress,
                        contents: "Push the button: \(confirmation.url())"
                    )
                }
                .flatMap { email in
                    self.req.queue.dispatch(SendEmailJob.self, email)
                }
        } catch {
            return req.eventLoop.future(error: error)
        }
    }
}

extension Confirmation {
    func url() throws -> String {
        try "puffery://puffery.app/confirmations/\(scope)/\(requireID())"
    }
}
