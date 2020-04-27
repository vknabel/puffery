import Vapor

struct CreateUserRequest: Content {
    var device: CreateDeviceRequest?
    var email: String?
    var password: String?
}

struct CreateCredentialsRequest: Content {
    var email: String
    var password: String
}

struct UpdateCredentialsRequest: Content {
    var email: String?
    var password: String?
    var oldPassword: String?
}

struct LoginUserRequest: Content {
    var email: String
    var password: String
}

struct CreateChannelRequest: Content {
    var title: String
}

struct CreateSubscriptionRequest: Content {
    var receiveOrNotifyKey: String
}

struct CreateMessageRequest: Content {
    var title: String
    var body: String
    var color: String?
}

struct CreateDeviceRequest: Content {
    var token: String
    var isProduction: Bool?
}

struct CreateOrUpdateDeviceRequest: Content {
    var isProduction: Bool?
}
