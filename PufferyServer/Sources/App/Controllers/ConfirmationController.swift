import APIDefinition
import Fluent
import Vapor

final class ConfirmationController {
    func confirmLogin(_ req: Request) async throws -> TokenResponse {
        guard let confirmationId = req.parameters.get("confirmation_id").flatMap(UUID.init(uuidString:)) else {
            throw ApiError(.invalidCredentials)
        }
        let confirmation = try await Confirmation.query(on: req.db)
            .filter(\Confirmation.$id == confirmationId)
            .filter(\Confirmation.$scope == "login")
            .with(\.$user)
            .first()

        guard let confirmation = confirmation else {
            throw Abort(.notFound)
        }

        let token = try confirmation.user.generateToken()
        try await token.create(on: req.db)
        return try TokenResponse(
            token: token.value,
            user: UserResponse(
                id: confirmation.user.requireID(),
                email: confirmation.user.email,
                isConfirmed: confirmation.user.isConfirmed
            )
        )
    }

    func confirmEmail(_ req: Request) async throws -> ConfirmedEmailResponse {
        guard let confirmationId = req.parameters.get("confirmation_id").flatMap(UUID.init(uuidString:)) else {
            throw ApiError(.invalidCredentials)
        }
        let confirmation = try await Confirmation.query(on: req.db)
            .filter(\Confirmation.$id == confirmationId)
            .filter(\Confirmation.$scope == "email")
            .with(\.$user)
            .first()

        guard let confirmation = confirmation else {
            throw Abort(.notFound)
        }
        guard confirmation.user.email == confirmation.snapshot else {
            throw ApiError(.confirmationExpired)
        }
        confirmation.user.isConfirmed = true
        try await confirmation.user.save(on: req.db)
        return ConfirmedEmailResponse()
    }
}
