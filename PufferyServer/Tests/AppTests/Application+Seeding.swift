import Vapor
@testable import App

extension Application {
    func seedUser(email: String? = nil, isConfirmed: Bool = false) throws -> User {
        try User(email: email, isConfirmed: isConfirmed)
            .saving(on: db)
            .wait()
    }
    
    func seedChannel(title: String = "My Test Channel") throws -> App.Channel {
        try App.Channel(title: title)
            .saving(on: db)
            .wait()
    }
    
    func seedSubscription(
        user: User,
        channel: App.Channel,
        canNotify: Bool = .random(),
        isSilent: Bool = .random()
    ) throws -> Subscription {
        try Subscription(user: user, channel: channel, canNotify: canNotify, isSilent: isSilent)
            .saving(on: db)
            .wait()
    }
}
