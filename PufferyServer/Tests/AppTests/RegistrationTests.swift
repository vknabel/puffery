import App
import APIDefinition
import XCTVapor

final class RegistrationTests: PufferyTestCase {
    func testBasicRegistration() throws {
        let content = CreateUserRequest(device: nil)
        
        try app.testValidPostRegister(content) { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(TokenResponse.self)
            XCTAssertEqual(token.user.isConfirmed, false)
            XCTAssertNil(token.user.email)
        }
    }
    
    func testRegistrationWithDevice() throws {
        let content = CreateUserRequest(device: CreateDeviceRequest(token: "my-random-token", isProduction: false))
        
        try app.testValidPostRegister(content) { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(TokenResponse.self)
            XCTAssertEqual(token.user.isConfirmed, false)
            XCTAssertNil(token.user.email)
        }
    }

    func testRegistrationWithoutDeviceButEmail() throws {
        let content = CreateUserRequest(
            device: nil,
            email: "hello-puffery@mail.com"
        )
        
        try app.testValidPostRegister(content) { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(TokenResponse.self)
            XCTAssertEqual(token.user.isConfirmed, false)
            XCTAssertEqual(token.user.email, "hello-puffery@mail.com")
        }
    }
    
    func testRegistrationWithDeviceAndEmail() throws {
        let content = CreateUserRequest(
            device: CreateDeviceRequest(token: "my-random-token", isProduction: false),
            email: "hello-puffery@mail.com"
        )
        
        try app.testValidPostRegister(content) { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(TokenResponse.self)
            XCTAssertEqual(token.user.isConfirmed, false)
            XCTAssertEqual(token.user.email, "hello-puffery@mail.com")
        }
    }
}

private extension Application {
    @discardableResult
    func testValidPostRegister(
        _ content: CreateUserRequest,
        file: StaticString = #file,
        line: UInt = #line,
        afterResponse: @escaping (XCTHTTPResponse) throws -> ()) throws -> XCTApplicationTester {
        try test(
            .POST, "register",
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
