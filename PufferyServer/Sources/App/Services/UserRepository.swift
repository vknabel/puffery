import Fluent
import Vapor

extension Request {
    var users: UserRepository { UserRepository(req: self) }
}

struct UserRepository {
    var req: Request

    func setCredentials(_ user: User, email: String?, password: String?) -> EventLoopFuture<Void> {
        if let password = password {
            return req.password.async.hash(password)
                .flatMap { (passwordHash: String) in
                    if let email = email {
                        user.$email.value = email
                    }
                    user.$passwordHash.value = passwordHash
                    return user.save(on: self.req.db)
                }
        } else if let email = email {
            user.email = email
            return user.save(on: req.db)
        } else {
            return req.eventLoop.future()
        }
    }
}
