import Vapor

final class UserController {
    func create(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        let createRequest = try req.content.decode(CreateUserRequest.self)
        let newUser = User(email: createRequest.email)
        return newUser.save(on: req.db)
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
                    let tokenResponse = try TokenResponse(
                        token: token.value,
                        user: UserResponse(id: user.requireID(), email: user.email)
                    )
                    return token.create(on: req.db).transform(to: tokenResponse)
                } else {
                    return req.eventLoop.future(error: ApiError.invalidCredentials)
                }
            }
    }
}
