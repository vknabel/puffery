import Fluent
import Vapor

final class Confirmation: Model {
    static var schema: String = "confirmations"

    @ID(key: "id")
    var id: UUID?

    @Field(key: "scope")
    var scope: String
    @Field(key: "snapshot")
    var snapshot: String?

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "expires_at", on: .delete)
    var expiresAt: Date?

    var isValid: Bool {
        (expiresAt ?? Date()) > Date()
    }

    init() {}

    init(id: UUID? = nil, scope: String, snapshot: String?, user: User, expiresAt: Date? = nil) throws {
        self.id = id
        self.scope = scope
        self.snapshot = snapshot
        $user.value = user
        $user.id = try user.requireID()
        self.expiresAt = expiresAt ?? Date(timeIntervalSinceNow: 120.minutes)
    }
}

private extension Int {
    var minutes: TimeInterval {
        TimeInterval(self * 60)
    }
}
