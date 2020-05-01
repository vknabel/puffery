import XCTest
@testable import PufferyKit

final class PufferyKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PufferyKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
