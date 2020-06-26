import App
import XCTest
import XCTVapor
import FluentSQL

class PufferyTestCase: XCTVaporTests {
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
}
