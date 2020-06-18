import Foundation

extension Notification.Name {
    public static var didUnsubscribeFromChannel: Notification.Name {
        Notification.Name(rawValue: "DID_UNSUBSCRIBE_FROM_CHANNEL")
    }

    public static var didSubscribeToChannel: Notification.Name {
        Notification.Name(rawValue: "DID_SUBSCRIBE_TO_CHANNEL")
    }

    public static var receivedMessage: Notification.Name {
        Notification.Name(rawValue: "DID_OPEN_CHANNEL_MESSAGE")
    }
}

@objc public final class ReceivedMessageNotification: NSObject {
    public let receivedMessageID: UUID
    public let subscribedChannelID: UUID

    public init(receivedMessageID: UUID, subscribedChannelID: UUID) {
        self.receivedMessageID = receivedMessageID
        self.subscribedChannelID = subscribedChannelID
    }
}
