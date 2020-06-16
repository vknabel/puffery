import Foundation

extension Notification.Name {
    public static var didUnsubscribeFromChannel: Notification.Name {
        Notification.Name(rawValue: "DID_UNSUBSCRIBE_FROM_CHANNEL")
    }
    
    public static var didSubscribeFromChannel: Notification.Name {
        Notification.Name(rawValue: "DID_SUBSCRIBE_FROM_CHANNEL")
    }
}
