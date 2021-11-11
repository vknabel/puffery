import APIDefinition
import Fluent
import Vapor

final class UserController {
    func create(_ req: Request) async throws -> TokenResponse {
        do {
            try CreateUserRequest.validate(content: req)
            let createRequest = try req.content.decode(CreateUserRequest.self)
            let newUser = User(email: createRequest.email)

            try await newUser.save(on: req.db)
            try await req.users.confirmEmailIfNeeded(newUser)

            if let device = createRequest.device {
                try await DeviceToken(
                    user: newUser, token: device.token, isProduction: device.isProduction ?? true
                )
                .create(on: req.db)
            }
            let token = try newUser.generateToken()
            try await token.create(on: req.db)

            let userResponse = try UserResponse(id: newUser.requireID(), email: newUser.email, isConfirmed: newUser.isConfirmed)
            return TokenResponse(token: token.value, user: userResponse)
        } catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                throw Abort(.conflict, reason: "User already exists")
            } else {
                throw error
            }
        }
    }

    func login(_ req: Request) async throws -> LoginAttemptResponse {
        let loginUser = try req.content.decode(LoginUserRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\User.$email == loginUser.email)
            .first()
        else {
            throw ApiError(.invalidCredentials)
        }
        try await req.users.sendLoginConfirmation(user)
        return LoginAttemptResponse()

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

    func updateProfile(_ req: Request) async throws -> UserResponse {
        let user = try req.auth.require(User.self)
        try UpdateProfileRequest.validate(content: req)
        let profile = try req.content.decode(UpdateProfileRequest.self)

        if let email = profile.email {
            user.email = email
            user.isConfirmed = false
        }

        try await user.save(on: req.db)
        try await req.users.confirmEmailIfNeeded(user)

        return try UserResponse(id: user.requireID(), email: user.email, isConfirmed: user.isConfirmed)
    }

    func deleteUser(_ req: Request) async throws -> HTTPResponseStatus {
        let user = try req.auth.require(User.self)
        try await user.delete(on: req.db)
        return HTTPResponseStatus.ok
    }
}

extension UpdateProfileRequest: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email, required: true)
    }
}

extension CreateUserRequest: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email, required: false)
    }
}
