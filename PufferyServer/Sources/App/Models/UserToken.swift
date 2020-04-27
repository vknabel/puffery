import Crypto
import Fluent
import Vapor

/// An ephermal authentication token that identifies a registered user.
final class UserToken: Model {
    static let schema = "user_tokens"

//    /// Creates a new `UserToken` for a given user.
//    static func create(userID: User.ID) throws -> UserToken {
//        // generate a random 128-bit, base64-encoded string.
//        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
//        // init a new `UserToken` from that string.
//        return .init(string: string, userID: userID)
//    }

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() {}

    /// Creates a new `UserToken`.
    init(id: UUID? = nil, value: String, user: User) throws {
        self.id = id
        self.value = value
        $user.id = try user.requireID()
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

    var isValid: Bool {
        true
    }
}
