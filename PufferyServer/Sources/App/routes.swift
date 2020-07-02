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

    let apiV1 = app.grouped("api", "v1")
    
    let bearer = apiV1.grouped(UserToken.authenticator()).grouped(UserBearerAuthenticator())

    let userController = UserController()
    apiV1.post("register", use: userController.create)
    apiV1.post("login", use: userController.login)

    let confirmationController = ConfirmationController()
    apiV1.post("confirmations", "login", ":confirmation_id", use: confirmationController.confirmLogin)
    apiV1.post("confirmations", "email", ":confirmation_id", use: confirmationController.confirmEmail)

    bearer.get("profile", use: userController.profile)
    bearer.put("profile", use: userController.updateProfile)

    let subscribedChannelController = SubscribedChannelController()
    let messageController = MessageController()
    let deviceController = DeviceController()

    bearer.post("devices", use: deviceController.create)
    bearer.put("devices", ":device_token", use: deviceController.createOrUpdate)

    bearer.post("channels", use: subscribedChannelController.create)
    bearer.get("channels", ":subscription_id", use: subscribedChannelController.details)
    bearer.post("channels", ":subscription_id", use: subscribedChannelController.update)
    bearer.delete("channels", ":subscription_id", use: subscribedChannelController.unsubscribe)
    bearer.get("channels", use: subscribedChannelController.index)
    bearer.get("channels", "shared", use: subscribedChannelController.indexShared)
    bearer.get("channels", "own", use: subscribedChannelController.indexOwn)

    apiV1.on(.POST, "notify", "inbound-email", body: HTTPBodyStreamStrategy.collect(maxSize: nil), use: messageController.publicEmail)
    apiV1.post("notify", ":notify_key", use: messageController.publicNotify)
    bearer.get("channels", "messages", use: messageController.messagesForAllChannels)
    bearer.get("channels", ":subscription_id", "messages", use: messageController.index)
    bearer.post("channels", ":subscription_id", "messages", use: messageController.create)

    bearer.post("channels", "subscribe", use: subscribedChannelController.subscribe)
}
