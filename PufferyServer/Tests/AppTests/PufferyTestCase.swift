@testable import App
import FluentSQL
import XCTest
import XCTVapor

class PufferyTestCase: XCTVaporTests {
    var sentMessage: Message?

    override class func setUp() {
        XCTVapor.app = {
            let app = Application(.testing)

            try configure(app)
            let sql = app.db(.psql) as! SQLDatabase
            try sql.raw("DROP SCHEMA public CASCADE").run().wait()
            try sql.raw("CREATE SCHEMA public").run().wait()

            try app.autoMigrate().wait()
            return app
        }
    }

    override func setUp() {
        super.setUp()

        sentMessage = nil
        app.mockPushService { [unowned self] message in
            self.sentMessage = message
        }
    }

    override func tearDown() {
        sentMessage = nil
        app.unmockPushService()
        super.tearDown()
    }
}
