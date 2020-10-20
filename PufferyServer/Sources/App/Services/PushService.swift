import APNS
import Fluent
import Vapor
import Queues

struct PushServiceFactoryStorageKey: StorageKey {
    typealias Value = (EventLoop, APNSwiftClient, Logger, Database) -> PushService
}

extension Request {
    var push: PushService {
        (application.storage[PushServiceFactoryStorageKey.self] ?? APNSPushService.init)(
            eventLoop,
            apns,
            logger,
            db
        )
    }
}

extension QueueContext {
    var push: PushService {
        (application.storage[PushServiceFactoryStorageKey.self] ?? APNSPushService.init)(
            eventLoop,
            application.apns,
            logger,
            application.db
        )
    }
}

protocol PushService {
    func notifyDevices(message: Message) -> EventLoopFuture<Void>
}

struct APNSPushService: PushService {
    let eventLoop: EventLoop
    let apns: APNSwiftClient
    let logger: Logger
    let db: Database
    
    func notifyDevices(message: Message) -> EventLoopFuture<Void> {
        notifiableSubscriptions(message: message)
            .flatMap { subscriptions in
                eventLoop.flatten(
                    subscriptions.map { subscription in
                        self.notifyDevices(subscription: subscription, message: message)
                    }
                )
            }
            .always { _ in
                logger.info("Sent Push Notification", source: "APNSPushService")
            }
    }

    private func notifyDevices(subscription: Subscription, message: Message) -> EventLoopFuture<Void> {
        notifiableDeviceTokens(subscription: subscription)
            .map { tokens in
                tokens.unique(\.token).filter { !$0.token.isEmpty }
            }
            .flatMap { tokens in
                eventLoop.flatten(
                    tokens.map { self.send(message: message, to: $0, for: subscription) }
                )
            }
    }

    private func send(message: Message, to device: DeviceToken, for subscription: Subscription) -> EventLoopFuture<Void> {
        let notif: ReceivedMessageNotification
        do {
            notif = try subscribedChannelNotification(for: message, subscription: subscription)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        return apns.send(notif, to: device.token)
            .flatMapError { (error) -> EventLoopFuture<Void> in
                if case .badRequest(.badDeviceToken) = error as? APNSwiftError.ResponseError {
                    logger.info("APN Removing bad device token", metadata: [
                        "token": .string(device.token),
                        "message": .string(message.id?.uuidString ?? "nil"),
                    ])
                    return device.delete(on: db)
                } else if case .badRequest(.unregistered) = error as? APNSwiftError.ResponseError {
                    logger.info("APN Removing unregistered", metadata: [
                        "token": .string(device.token),
                        "message": .string(message.id?.uuidString ?? "nil"),
                    ])
                    return device.delete(on: db)
                } else if let signingError = error as? APNSwiftError.SigningError {
                    logger.critical("APN Signing error \(signingError)")
                    return eventLoop.future(error: error)
                } else {
                    logger.info("APN delivery failed \(error)")
                    return eventLoop.future()
                }
            }
    }

    private func subscribedChannelNotification(for message: Message, subscription: Subscription) throws -> ReceivedMessageNotification {
        try ReceivedMessageNotification(
            message: message,
            subscription: subscription,
            aps: APNSwiftPayload(
                alert: APNSwiftAlert(
                    title: "\(message.channel.title): \(message.title)",
                    body: message.body
                ),
                badge: 1
            )
        )
    }

    private func notifiableSubscriptions(message: Message) -> EventLoopFuture<[Subscription]> {
        Subscription.query(on: db)
            .filter(Subscription.self, \Subscription.$channel.$id == message.$channel.id)
            .filter(Subscription.self, \Subscription.$isSilent != true)
            .all()
    }

    private func notifiableDeviceTokens(subscription: Subscription) -> EventLoopFuture<[DeviceToken]> {
        let subscriptionId: UUID
        do {
            subscriptionId = try subscription.requireID()
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        return DeviceToken.query(on: db)
            .join(User.self, on: \DeviceToken.$user.$id == \User.$id, method: .inner)
            .join(Subscription.self, on: \User.$id == \Subscription.$user.$id)
            .filter(Subscription.self, \Subscription.$id == subscriptionId)
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
