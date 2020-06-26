import PufferyKit
import UIKit

public enum DeepLinking {
    public static func open(context: UIOpenURLContext, rootViewController: UIViewController?) {
        var components = context.url.pathComponents
            .filter { $0 != "/" }
        let first = components.popFirst()
        let second = components.popFirst()
        let third = components.popFirst()

        switch (first, second, third) {
        case let ("confirmations", "login", confirmationID?):
            Current.api.confirmLogin(confirmationID)
                .task { _ in }
        case let ("confirmations", "email", confirmationID?):
            Current.api.confirmEmail(confirmationID)
                .task { _ in }
        case let ("channels", "subscribe", receiveOrNotifyKey?):
            func subscribe(isSilent: Bool) {
                let createRequest = CreateSubscriptionRequest(receiveOrNotifyKey: receiveOrNotifyKey, isSilent: isSilent)
                Current.api.subscribe(createRequest)
                    .task { _ in
                        NotificationCenter.default.post(
                            name: .didSubscribeToChannel,
                            object: nil
                        )
                    }
            }
            
            let alert = UIAlertController(title: "ChannelSubscribingAlert.Title", message: "ChannelSubscribingAlert.Message", preferredStyle: UIAlertController.Style.actionSheet)
            alert.addAction(UIAlertAction(
                title: "ChannelSubscribingAlert.Receive",
                style: .default,
                handler: { _ in
                    PushNotifications.register {
                        subscribe(isSilent: false)
                    }
            }))
            alert.addAction(UIAlertAction(
                title: "ChannelSubscribingAlert.Silent",
                style: .default,
                handler: { _ in subscribe(isSilent: true) }
            ))
            alert.addAction(UIAlertAction(title: "ChannelSubscribingAlert.Cancel", style: .cancel, handler: { _ in subscribe(isSilent: false) }))
            rootViewController?.present(alert, animated: true)
        default:
            print("Unknown URL")
        }
    }
}

fileprivate extension Array {
    mutating func popFirst() -> Element? {
        if isEmpty {
            return nil
        } else {
            return removeFirst()
        }
    }
}
