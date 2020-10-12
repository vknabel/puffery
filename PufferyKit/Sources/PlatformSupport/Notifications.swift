import Foundation

extension Notification.Name {
    public static var didUnsubscribeFromChannel: Notification.Name {
        Notification.Name(rawValue: "DID_UNSUBSCRIBE_FROM_CHANNEL")
    }

    public static var didSubscribeToChannel: Notification.Name {
        Notification.Name(rawValue: "DID_SUBSCRIBE_TO_CHANNEL")
    }

    public static var didChangeChannel: Notification.Name {
        Notification.Name(rawValue: "DID_CHANGE_CHANNEL")
    }

    public static var receivedMessage: Notification.Name {
        Notification.Name(rawValue: "DID_OPEN_CHANNEL_MESSAGE")
    }
}

@objc public final class ReceivedMessageNotification: NSObject {
    public let messageID: UUID
    public let channelID: UUID?

    public init(messageID: UUID, channelID: UUID?) {
        self.messageID = messageID
        self.channelID = channelID
    }
}
