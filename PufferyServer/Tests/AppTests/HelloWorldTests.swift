import XCTest

final class HelloWorldTests: PufferyTestCase {
    func testHelloWorldSucceeds() throws {
        try app.test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        }
    }
}
