import Fluent
import Vapor

final class Message: Model {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    @Field(key: "body")
    var body: String
    @Field(key: "color")
    var color: String?
    @Parent(key: "channel_id")
    var channel: Channel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, channel: Channel, title: String, body: String, color: String?) throws {
        self.id = id
        $channel.id = try channel.requireID()
        $channel.value = channel
        self.title = title
        self.body = body
        self.color = color
    }
}

/// Allows `Message` to be used as a dynamic migration.
struct CreateMessageMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Message.schema)
            .id()
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("color", .string)
            .field("created_at", .datetime, .required)
            .field("channel_id", .uuid, .references(Channel.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Message.schema).delete()
    }
}
