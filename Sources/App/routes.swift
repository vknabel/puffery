import Vapor

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    // Basic "It works" example
    app.get { _ in
        "It works!"
    }

    // Basic "Hello, world!" example
    app.get("hello") { _ in
        "Hello, world!"
    }

    // POST channels/:id/messages -> with private token somewhere
    // POST notify/:private
    // POST subscriptions

    let userController = UserController()
    app.post("register", use: userController.create)
    app.post("login", use: userController.login)

    let bearer = app.grouped(UserToken.authenticator())
    let subscribedChannelController = SubscribedChannelController()
    let messageController = MessageController()
    let deviceController = DeviceController()

    bearer.post("devices", use: deviceController.create)
    bearer.put("devices", ":device_token", use: deviceController.createOrUpdate)

    bearer.post("channels", use: subscribedChannelController.create)
    bearer.get("channels", use: subscribedChannelController.index)

    app.post("notify", ":notify_key", use: messageController.publicNotify)
    bearer.post("channels", ":subscription_id", "messages", use: messageController.create)
    bearer.get("channels", ":subscription_id", "messages", use: messageController.index)

    bearer.post("channels", "subscribe", use: subscribedChannelController.subscribe)
}
