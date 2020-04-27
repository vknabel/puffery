import Fluent
import Vapor

struct UserCredentialsAuthenticator: CredentialsAuthenticator {
    typealias Credentials = LoginUserRequest

    func authenticate(credentials: LoginUserRequest, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db)
            .filter(\User.$email == credentials.email)
            .first()
            .flatMap { user in
                guard let user = user, let passwordHash = user.passwordHash else {
                    return request.eventLoop.future(error: ApiError(.invalidCredentials))
                }
                return request.password.async.verify(credentials.password, created: passwordHash)
                    .flatMap { isValid in
                        if isValid {
                            request.auth.login(user)
                            return request.eventLoop.future()
                        } else {
                            return request.eventLoop.future(error: ApiError(.invalidCredentials))
                        }
                    }
            }
    }
}
