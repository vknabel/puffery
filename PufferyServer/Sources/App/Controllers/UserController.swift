import Fluent
import Vapor
import APIDefinition

final class UserController {
    func create(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        let createRequest = try req.content.decode(CreateUserRequest.self)
        let newUser = User(email: createRequest.email)

        return newUser.save(on: req.db)
            .flatMap { _ in
                req.users.confirmEmailIfNeeded(newUser)
            }
            .flatMap { _ -> EventLoopFuture<Void> in
                if let device = createRequest.device {
                    do {
                        return try DeviceToken(user: newUser, token: device.token, isProduction: device.isProduction ?? true)
                            .create(on: req.db)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                } else {
                    return req.eventLoop.makeSucceededFuture(())
                }
            }
            .flatMapThrowing { _ in
                try newUser.generateToken()
            }
            .flatMap { token in
                token.create(on: req.db).transform(to: token)
            }
            .flatMapThrowing { token in
                let userResponse = try UserResponse(id: newUser.requireID(), email: newUser.email, isConfirmed: newUser.isConfirmed)
                return TokenResponse(token: token.value, user: userResponse)
            }
    }

    func login(_ req: Request) throws -> EventLoopFuture<LoginAttemptResponse> {
        let loginUser = try req.content.decode(LoginUserRequest.self)

        return User.query(on: req.db)
            .filter(\User.$email == loginUser.email)
            .first()
            .flatMap { (user: User?) -> EventLoopFuture<Void> in
                user.map(req.users.sendLoginConfirmation)
                    ?? req.eventLoop.future(error: ApiError(.invalidCredentials))
            }
            .transform(to: LoginAttemptResponse())

//        // Confirm
//        let token = try user.generateToken()
//        return token.create(on: req.db).flatMapThrowing { _ in
//            try TokenResponse(token: token.value, user: UserResponse(id: user.requireID(), email: user.email, isConfirmed: user.isConfirmed))
//        }
    }

    func profile(_ req: Request) throws -> UserResponse {
        let user = try req.auth.require(User.self)
        return try UserResponse(id: user.requireID(), email: user.email, isConfirmed: user.isConfirmed)
    }

    func updateProfile(_ req: Request) throws -> EventLoopFuture<UserResponse> {
        let user = try req.auth.require(User.self)
        try UpdateProfileRequest.validate(req)
        let profile = try req.content.decode(UpdateProfileRequest.self)

        if let email = profile.email {
            user.email = email
            user.isConfirmed = false
        }

        return user.save(on: req.db)
            .flatMap { _ in
                req.users.confirmEmailIfNeeded(user)
            }
            .flatMapThrowing { _ in
                try UserResponse(id: user.requireID(), email: user.email, isConfirmed: user.isConfirmed)
            }
    }
}

extension UpdateProfileRequest: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email, required: true)
    }
}
