import Fluent
import Vapor

final class Channel: Model {
    static let schema = "channels"

    @ID(key: .id)
    var id: UUID?
    @Field(key: "title")
    var title: String
    @Field(key: "notifyKey")
    var notifyKey: String
    @Field(key: "receiveOnlyKey")
    var receiveOnlyKey: String

    @Children(for: \.$channel)
    var messages: [Message]
    @Children(for: \.$channel)
    var subscriptions: [Subscription]

    init() {}

    init(id: UUID? = nil, title: String, notifyKey: String = UUID().uuidString, receiveOnlyKey: String = UUID().uuidString) {
        self.id = id
        self.title = title
        self.notifyKey = notifyKey
        self.receiveOnlyKey = receiveOnlyKey
    }
}
