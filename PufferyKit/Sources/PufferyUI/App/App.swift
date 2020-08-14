import UserNotifications
import PlatformSupport

public final class App {
    lazy var notifications = NotificationsService()

    public init() {}

    public func bootstrap() {
        UNUserNotificationCenter.current().delegate = notifications
    }

    public func didRegisterForRemoteNotifications(with deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Current.store.commit(.updateDeviceToken(token))
        if Current.store.state.session.isLoggedIn() {
            Current.api.createOrUpdate(device: token, contents: CreateOrUpdateDeviceRequest())
                .task { _ in }
        }
    }
}
