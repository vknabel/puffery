@testable import App
import Vapor

extension Application {
    func seedUser(email: String? = nil, isConfirmed: Bool = false) async throws -> User {
        try await User(email: email, isConfirmed: isConfirmed)
            .saving(on: db)
    }

    func seedChannel(title: String = "My Test Channel") async throws -> App.Channel {
        try await App.Channel(title: title)
            .saving(on: db)
    }

    func seedSubscription(
        user: User,
        channel: App.Channel,
        canNotify: Bool = .random(),
        isSilent: Bool = .random()
    ) async throws -> Subscription {
        try await Subscription(user: user, channel: channel, canNotify: canNotify, isSilent: isSilent)
            .saving(on: db)
    }

    func seedUserToken(user: User) async throws -> UserToken {
        let token = try user.generateToken()
        try token.create(on: db).wait()
        return token
    }

    func seedMessage(
        channel: App.Channel,
        title: String = "You got news!",
        body: String = "Test contents",
        color: String? = nil
    ) async
    throws -> Message {
        try await Message(
            channel: channel,
            title: title,
            body: body,
            color: color
        )
        .saving(on: db)
    }
}
