import Vapor

struct UserBearerAuthenticator: BearerAuthenticator {
    typealias User = App.User

    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        authenticateUser(bearer: bearer, for: request)
            .map { user in
                if let user = user {
                    request.auth.login(user)
                }
            }
    }

    func authenticateUser(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<User?> {
        UserToken.query(on: request.db)
            .filter(\.$value, .equal, bearer.token)
            .with(\.$user)
            .first()
            .map { token in
                if let token = token, token.isValid {
                    return token.user
                } else {
                    return nil
                }
            }
    }
}
