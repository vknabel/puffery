import Vapor

final class UserController {
    func create(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        let createRequest = try req.content.decode(CreateUserRequest.self)
        guard createRequest.email == nil && createRequest.password == nil || createRequest.email != nil && createRequest.password != nil else {
            throw ApiError(.invalidCredentials)
        }
        let newUser = try User(
            email: createRequest.email,
            passwordHash: createRequest.password.map(req.password.hash)
        )
        return newUser.save(on: req.db)
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
                let userResponse = try UserResponse(id: newUser.requireID(), email: newUser.email)
                return TokenResponse(token: token.value, user: userResponse)
            }
    }

    func login(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.create(on: req.db).flatMapThrowing { _ in
            try TokenResponse(token: token.value, user: UserResponse(id: user.requireID(), email: user.email))
        }
    }

    func profile(_ req: Request) throws -> UserResponse {
        let user = try req.auth.require(User.self)
        return try UserResponse(id: user.requireID(), email: user.email)
    }

    func updateCredentials(_ req: Request) throws -> EventLoopFuture<UserResponse> {
        let user = try req.auth.require(User.self)
        try UpdateCredentialsRequest.validate(req)
        let credentials = try req.content.decode(UpdateCredentialsRequest.self)

        guard user.email == credentials.email else {
            throw ApiError(.invalidCredentials)
        }

        let isCurrentPasswordValid: EventLoopFuture<Bool>
        if let currentPasswordHash = user.passwordHash {
            guard let oldPassword = credentials.oldPassword else {
                throw ApiError(.invalidCredentials)
            }
            isCurrentPasswordValid = req.password.async.verify(oldPassword, created: currentPasswordHash)
        } else {
            isCurrentPasswordValid = req.eventLoop.makeSucceededFuture(true)
        }
        return isCurrentPasswordValid.flatMap { isValid in
            isValid
                ? req.users.setCredentials(user, email: credentials.email, password: credentials.password)
                : req.eventLoop.future(error: ApiError(.invalidCredentials))
        }
        .flatMapThrowing { _ in
            try UserResponse(id: user.requireID(), email: user.email)
        }
    }
}

extension CreateCredentialsRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email, required: true)
        validations.add("password", as: String.self, is: .count(8...), required: true)
    }
}

extension UpdateCredentialsRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email, required: false)
        validations.add("password", as: String.self, is: .count(8...), required: false)
        validations.add("oldPassword", as: String.self, is: .count(8...), required: true)
    }
}
