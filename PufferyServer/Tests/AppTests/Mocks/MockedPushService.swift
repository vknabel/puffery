@testable import App
import Vapor
import XCTest

struct MockedPushService: PushService {
    let req: Request
    let receiveMessage: (Message) -> Void

    func notifyDevices(message: Message) -> EventLoopFuture<Void> {
        receiveMessage(message)
        return req.eventLoop.makeSucceededFuture(())
    }
}

extension Application {
    @discardableResult
    func mockPushService(receive: @escaping (Message) -> Void) -> Application {
        storage[PushServiceFactoryStorageKey.self] = { req in
            MockedPushService(req: req, receiveMessage: receive)
        }
        return self
    }

    @discardableResult
    func unmockPushService() -> Application {
        storage[PushServiceFactoryStorageKey.self] = nil
        return self
    }
}
