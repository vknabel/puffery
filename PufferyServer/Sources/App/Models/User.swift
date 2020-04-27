import Fluent
import Vapor

final class User: Model, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String?

    @Children(for: \.$user)
    var subscriptions: [Subscription]

    init() {}

    init(id: UUID? = nil, email: String?) {
        self.id = id
        self.email = email
    }
}

/// Allows users to be verified by bearer / token auth middleware.
extension User {
    func generateToken() throws -> UserToken {
        try UserToken(
            value: [UInt8].random(count: 16).base64,
            user: self
        )
    }
}
