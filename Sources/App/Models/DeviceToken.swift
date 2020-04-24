import Fluent
import Vapor

final class DeviceToken: Model {
    static let schema = "devices"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User
    @Field(key: "token")
    var token: String
    @Field(key: "is_production")
    var isProduction: Bool

    init() {}

    init(id: UUID? = nil, user: User, token: String, isProduction: Bool) throws {
        self.id = id
        $user.id = try user.requireID()
        self.token = token
        self.isProduction = isProduction
    }
}
