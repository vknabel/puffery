import Fluent
import Vapor
import APIDefinition

final class ConfirmationController {
    func confirmLogin(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        guard let confirmationId = req.parameters.get("confirmation_id").flatMap(UUID.init(uuidString:)) else {
            throw ApiError(.invalidCredentials)
        }
        return Confirmation.query(on: req.db)
            .filter(\Confirmation.$id == confirmationId)
            .filter(\Confirmation.$scope == "login")
            .with(\.$user)
            .first()

            .flatMap { (confirmation: Confirmation?) -> EventLoopFuture<TokenResponse> in
                guard let confirmation = confirmation else {
                    return req.eventLoop.future(error: Abort(.notFound))
                }
                do {
                    let token = try confirmation.user.generateToken()
                    return token.create(on: req.db).flatMapThrowing { _ in
                        try TokenResponse(
                            token: token.value,
                            user: UserResponse(
                                id: confirmation.user.requireID(),
                                email: confirmation.user.email,
                                isConfirmed: confirmation.user.isConfirmed
                            )
                        )
                    }
                } catch {
                    return req.eventLoop.future(error: error)
                }
            }
    }

    func confirmEmail(_ req: Request) throws -> EventLoopFuture<ConfirmedEmailResponse> {
        guard let confirmationId = req.parameters.get("confirmation_id").flatMap(UUID.init(uuidString:)) else {
            throw ApiError(.invalidCredentials)
        }
        return Confirmation.query(on: req.db)
            .filter(\Confirmation.$id == confirmationId)
            .filter(\Confirmation.$scope == "email")
            .with(\.$user)
            .first()

            .flatMap { (confirmation: Confirmation?) in
                guard let confirmation = confirmation else {
                    return req.eventLoop.future(error: Abort(.notFound))
                }
                guard confirmation.user.email == confirmation.snapshot else {
                    return req.eventLoop.future(error: ApiError(.confirmationExpired))
                }
                confirmation.user.isConfirmed = true
                return confirmation.user.save(on: req.db)
                    .transform(to: ConfirmedEmailResponse())
            }
    }
}
