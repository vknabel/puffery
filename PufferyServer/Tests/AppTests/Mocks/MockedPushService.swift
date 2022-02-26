import APNSwift
@testable import App
import Fluent
import Vapor
import XCTest

struct MockedPushService: PushService {
    let eventLoop: EventLoop
    let apns: APNSwiftClient
    let logger: Logger
    let database: Database
    let receiveMessage: (Message) -> Void

    func notifyDevices(message: Message) async throws -> Void {
        receiveMessage(message)
    }
}

extension Application {
    @discardableResult
    func mockPushService(receive: @escaping (Message) -> Void) -> Application {
        storage[PushServiceFactoryStorageKey.self] = { loop, apns, logger, db in
            MockedPushService(eventLoop: loop, apns: apns, logger: logger, database: db, receiveMessage: receive)
        }
        return self
    }

    @discardableResult
    func unmockPushService() -> Application {
        storage[PushServiceFactoryStorageKey.self] = nil
        return self
    }
}
