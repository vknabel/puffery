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
        notifiableDeviceTokens(message: message)
            .flatMap { devices in
                let apnsSends = devices.unique(\.token).filter { !$0.token.isEmpty }.map { device in
                    self.send(message: message, to: device)
                }
                return self.req.eventLoop.flatten(apnsSends)
            }
    }

    private func send(message: Message, to device: DeviceToken) -> EventLoopFuture<Void> {
        req.apns.send(apnPayload(for: message), to: device.token)
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

    private func apnPayload(for message: Message) -> APNSwiftPayload {
        APNSwiftPayload(
            alert: APNSwiftPayload.APNSwiftAlert(
                title: "\(message.channel.title): \(message.title)",
                body: message.body,
                titleLocKey: nil,
                titleLocArgs: nil,
                actionLocKey: nil,
                locKey: nil,
                locArgs: nil,
                launchImage: nil
            ),
            badge: 1
        )
    }

    private func notifiableDeviceTokens(message: Message) -> EventLoopFuture<[DeviceToken]> {
        DeviceToken.query(on: req.db)
            .join(User.self, on: \DeviceToken.$user.$id == \User.$id, method: .inner)
            .join(Subscription.self, on: \User.$id == \Subscription.$user.$id)
            .join(Channel.self, on: \Subscription.$channel.$id == \Channel.$id)
            .filter(Channel.self, \Channel.$id == message.$channel.id)
            .all()
    }
}

private extension Sequence {
    func unique<V: Hashable>(_ prop: (Iterator.Element) -> V) -> [Iterator.Element] {
        var seen: Set<V> = []
        return filter { seen.insert(prop($0)).inserted }
    }
}
