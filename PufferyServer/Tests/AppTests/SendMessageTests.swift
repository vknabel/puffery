import APIDefinition
@testable import App
import XCTVapor

final class SendMessageTests: PufferyTestCase {
    func testPublicNotifyNotFound() throws {
        let content = CreateMessageRequest(
            title: "Hello World!",
            body: "How are you?",
            color: nil
        )
        try app.testPublicNotify(key: "", content, usingApiPrefix: false) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }

    func testPublicNotify() {
        asyncTest { [self] in
            let channel = try await app.seedChannel()

            let content = CreateMessageRequest(
                title: "Hello World!",
                body: "How are you?",
                color: nil
            )
            try app.testPublicNotify(key: channel.notifyKey, content, usingApiPrefix: false) { res in
                XCTAssertEqual(res.status, .ok)
                let message = try res.content.decode(NotifyMessageResponse.self)
                XCTAssertEqual(message.title, content.title)
                XCTAssertEqual(message.body, content.body)
                XCTAssertEqual(message.color, content.color)

                XCTAssertNotNil(self.sentMessage)
                XCTAssertEqual(self.sentMessage?.id, message.id)
                XCTAssertEqual(self.sentMessage?.title, content.title)
                XCTAssertEqual(self.sentMessage?.body, content.body)
                XCTAssertEqual(self.sentMessage?.color, content.color)
            }
        }
    }

    func testPublicNotifyWithLowercasedNotifyKey() {
        asyncTest { [self] in
            let channel = try await app.seedChannel()

            let content = CreateMessageRequest(
                title: "Hello World!",
                body: "How are you?",
                color: nil
            )
            try app.testPublicNotify(key: channel.notifyKey.lowercased(), content, usingApiPrefix: false) { res in
                XCTAssertEqual(res.status, .ok)
                let message = try res.content.decode(NotifyMessageResponse.self)
                XCTAssertEqual(message.title, content.title)
                XCTAssertEqual(message.body, content.body)
                XCTAssertEqual(message.color, content.color)

                XCTAssertNotNil(self.sentMessage)
                XCTAssertEqual(self.sentMessage?.id, message.id)
                XCTAssertEqual(self.sentMessage?.title, content.title)
                XCTAssertEqual(self.sentMessage?.body, content.body)
                XCTAssertEqual(self.sentMessage?.color, content.color)
            }
        }
    }
}

private extension Application {
    @discardableResult
    func testPublicNotify(
        key: String,
        _ content: CreateMessageRequest,
        usingApiPrefix: Bool,
        file: StaticString = #file,
        line: UInt = #line,
        afterResponse: @escaping (XCTHTTPResponse) throws -> Void
    ) throws -> XCTApplicationTester {
        try test(
            .POST, (usingApiPrefix ? "api/v1/" : "") + "notify/\(key)",
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            file: file,
            line: line,
            beforeRequest: { req in
                try req.content.encode(content)
            },
            afterResponse: afterResponse
        )
    }
}
