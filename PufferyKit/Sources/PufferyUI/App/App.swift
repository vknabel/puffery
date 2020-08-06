import UNUserNotificationCenter

public final class PufferyApp {
    lazy var notifications = NoitifcationsService()
    
    public init() {
        
    }
    
    func bootstrap() {
        UNUserNotificationCenter.current().delegate = notifications
    }
    
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Current.store.commit(.updateDeviceToken(token))
        if Current.store.state.session.isLoggedIn() {
            Current.api.createOrUpdate(device: token, contents: CreateOrUpdateDeviceRequest())
                .task { _ in }
        }
    }
}
