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

    let bearer = app.grouped(UserToken.authenticator()).grouped(UserBearerAuthenticator())

    let userController = UserController()
    app.post("register", use: userController.create)
    app.post("login", use: userController.login)

    let confirmationController = ConfirmationController()
    app.post("confirmations", "login", ":confirmation_id", use: confirmationController.confirmLogin)
    app.post("confirmations", "email", ":confirmation_id", use: confirmationController.confirmEmail)

    bearer.get("profile", use: userController.profile)
    bearer.put("profile", use: userController.updateProfile)

    let subscribedChannelController = SubscribedChannelController()
    let messageController = MessageController()
    let deviceController = DeviceController()

    bearer.post("devices", use: deviceController.create)
    bearer.put("devices", ":device_token", use: deviceController.createOrUpdate)

    bearer.post("channels", use: subscribedChannelController.create)
    bearer.delete("channels", ":subscription_id", use: subscribedChannelController.unsubscribe)
    bearer.get("channels", use: subscribedChannelController.index)
    bearer.get("channels", "shared", use: subscribedChannelController.indexShared)
    bearer.get("channels", "own", use: subscribedChannelController.indexOwn)

    app.on(.POST, "notify", "inbound-email", body: HTTPBodyStreamStrategy.collect(maxSize: nil), use: messageController.publicEmail)
    app.post("notify", ":notify_key", use: messageController.publicNotify)
    bearer.get("channels", "messages", use: messageController.messagesForAllChannels)
    bearer.get("channels", ":subscription_id", "messages", use: messageController.index)
    bearer.post("channels", ":subscription_id", "messages", use: messageController.create)

    bearer.post("channels", "subscribe", use: subscribedChannelController.subscribe)
}
