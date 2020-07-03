import Fluent
import Vapor

final class Subscription: Model {
    static let schema = "subscriptions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User
    @Parent(key: "channel_id")
    var channel: Channel
    @Field(key: "can_notify")
    var canNotify: Bool
    @Field(key: "is_silent")
    var isSilent: Bool

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, user: User, channel: Channel, canNotify: Bool, isSilent: Bool) throws {
        self.id = id
        $user.value = user
        $user.id = try user.requireID()
        $channel.value = channel
        $channel.id = try channel.requireID()
        self.canNotify = canNotify
        self.isSilent = isSilent
    }
}
