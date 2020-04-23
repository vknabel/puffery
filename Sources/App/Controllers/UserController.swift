import Vapor

final class UserController {
    func create(_ req: Request) throws -> EventLoopFuture<UserResponse> {
        let createRequest = try req.content.decode(CreateUserRequest.self)
        let newUser = User(email: createRequest.email)
        return newUser.save(on: req.db)
            .flatMapThrowing { _ in
                try UserResponse(id: newUser.requireID(), email: newUser.email)
            }
    }

    func login(_ req: Request) throws -> EventLoopFuture<UserToken> {
//        let user = try req.requireAuthenticated(User.self)
//        let token = try UserToken.create(userID: user.requireID())
//        return token.save(on: req)
        let loginRequest =
            try req.content.decode(LoginUserRequest.self)
        return User.query(on: req.db)
            .filter(\.$email, .equal, loginRequest.email)
            .first()
            .flatMap { user in
                if let user = user {
                    let token = try user.generateToken()
                    return token.create(on: req.db).transform(to: token)
                } else {
                    return req.eventLoop.future(error: ApiError.invalidCredentials)
                }
            }
    }
}

struct CreateUserRequest: Content {
    var email: String
}

struct LoginUserRequest: Content {
    var email: String
}

struct UserResponse: Content {
    var id: UUID
    var email: String
}
