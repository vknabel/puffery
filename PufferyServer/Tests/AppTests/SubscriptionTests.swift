import APIDefinition
@testable import App
import XCTVapor

final class SubscriptionTests: PufferyTestCase {
    func testPublicNotify() throws {
        let author = try app.seedUser()
        let channel = try app.seedChannel()
        let authorSubscription = try app.seedSubscription(user: author, channel: channel, canNotify: true)
        _ = try app.seedSubscription(user: app.seedUser(), channel: channel, canNotify: true)
        _ = try app.seedSubscription(user: app.seedUser(), channel: channel, canNotify: false)

        _ = try app.seedMessage(channel: channel)
        _ = try app.seedMessage(channel: channel)
        _ = try app.seedMessage(channel: channel)

        try app.testStatistics(
            subscriptionId: authorSubscription.requireID(),
            token: app.seedUserToken(user: author),
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let stats = try res.content.decode(SubscribedChannelStatisticsResponse.self)
                XCTAssertEqual(stats.notifiers, 2)
                XCTAssertEqual(stats.receivers, 1)
                XCTAssertEqual(stats.messages, 3)
            }
        )
    }
}

private extension Application {
    @discardableResult
    func testStatistics(
        subscriptionId: UUID,
        token: UserToken,
        file: StaticString = #file,
        line: UInt = #line,
        afterResponse: @escaping (XCTHTTPResponse) throws -> Void
    ) throws -> XCTApplicationTester {
        try test(
            .GET, "api/v1/channels/\(subscriptionId.uuidString)/stats",
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "Bearer \(token.value)",
            ],
            file: file,
            line: line,
            afterResponse: afterResponse
        )
    }
}
