import APNS
import Fluent
import Vapor

extension Request {
    var push: PushService {
        .init(req: self)
    }
}

struct PushService {
    let req: Request

    func notifyDevices(message: Message) -> EventLoopFuture<Void> {
        notifiableSubscriptions(message: message)
            .flatMap { subscriptions in
                self.req.eventLoop.flatten(
                    subscriptions.map { subscription in
                        self.notifyDevices(subscription: subscription, message: message)
                    }
                )
            }
    }

    private func notifyDevices(subscription: Subscription, message: Message) -> EventLoopFuture<Void> {
        notifiableDeviceTokens(subscription: subscription)
            .map { tokens in
                tokens.unique(\.token).filter { !$0.token.isEmpty }
            }
            .flatMap { tokens in
                self.req.eventLoop.flatten(
                    tokens.map { self.send(message: message, to: $0, for: subscription) }
                )
            }
    }

    private func send(message: Message, to device: DeviceToken, for subscription: Subscription) -> EventLoopFuture<Void> {
        let notif: SubscribedChannelNotification
        do {
            notif = try subscribedChannelNotification(for: message, subscription: subscription)
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
        return req.apns.send(notif, to: device.token)
            .flatMapError { (error) -> EventLoopFuture<Void> in
                if case .badRequest(.badDeviceToken) = error as? APNSwiftError.ResponseError {
                    self.req.logger.info("APN Removing bad device token", metadata: [
                        "token": .string(device.token),
                        "message": .string(message.id?.uuidString ?? "nil"),
                    ])
                    return device.delete(on: self.req.db)
                } else if case .badRequest(.unregistered) = error as? APNSwiftError.ResponseError {
                    self.req.logger.info("APN Removing unregistered", metadata: [
                        "token": .string(device.token),
                        "message": .string(message.id?.uuidString ?? "nil"),
                    ])
                    return device.delete(on: self.req.db)
                } else if let signingError = error as? APNSwiftError.SigningError {
                    self.req.logger.critical("APN Signing error \(signingError)")
                    return self.req.eventLoop.future(error: error)
                } else {
                    self.req.logger.info("APN delivery failed \(error)")
                    return self.req.eventLoop.future()
                }
            }
    }

    private func subscribedChannelNotification(for message: Message, subscription: Subscription) throws -> SubscribedChannelNotification {
        try ReceivedMessageNotification(
            message: message,
            subscription: subscription,
            aps: APNSwiftPayload(
                alert: APNSwiftPayload.APNSwiftAlert(
                    title: "\(message.channel.title): \(message.title)",
                    body: message.body
                ),
                badge: 1
            )
        )
    }

    private func notifiableSubscriptions(message: Message) -> EventLoopFuture<[Subscription]> {
        Subscription.query(on: req.db)
            .filter(Subscription.self, \Subscription.$channel.$id == message.$channel.id)
            .all()
    }

    private func notifiableDeviceTokens(subscription: Subscription) -> EventLoopFuture<[DeviceToken]> {
        DeviceToken.query(on: req.db)
            .join(User.self, on: \DeviceToken.$user.$id == \User.$id, method: .inner)
            .join(Subscription.self, on: \User.$id == \Subscription.$user.$id, method: .inner)
            .filter(Subscription.self, \Subscription.$channel.$id == subscription.$user.id)
            .all()
    }
}

private extension Sequence {
    func unique<V: Hashable>(_ prop: (Iterator.Element) -> V) -> [Iterator.Element] {
        var seen: Set<V> = []
        return filter { seen.insert(prop($0)).inserted }
    }
}

private struct ReceivedMessageNotification: APNSwiftNotification {
    let receivedMessageID: UUID
    let subscribedChannelID: UUID
    let aps: APNSwiftPayload

    init(message: Message, subscription: Subscription, aps: APNSwiftPayload) throws {
        subscribedChannelID = try subscription.requireID()
        receivedMessageID = try message.requireID()
        self.aps = aps
    }
}
