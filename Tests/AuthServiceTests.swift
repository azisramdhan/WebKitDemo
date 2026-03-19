import XCTest
@testable import WebKitDemo

final class AuthServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AuthService.shared.clearToken()
    }
    
    override func tearDown() {
        AuthService.shared.clearToken()
        super.tearDown()
    }
    
    func testLoginFailure() {
        let expectation = self.expectation(description: "Wait for login failure")
        
        AuthService.shared.login(username: "wronguser", password: "wrongpassword") { result in
            switch result {
            case .success(_):
                XCTFail("Login should have failed")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "AuthError")
                XCTAssertEqual(error.code, 401)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testClearToken() {
        AuthService.shared.saveToken("test_token")
        XCTAssertEqual(AuthService.shared.getValidToken(), "test_token")
        
        AuthService.shared.clearToken()
        XCTAssertNil(AuthService.shared.getValidToken())
    }
    
    func testLogout() {
        AuthService.shared.saveToken("test_token")
        let expectation = self.expectation(description: "Wait for logout completion")
        
        AuthService.shared.logout {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(AuthService.shared.getValidToken())
    }
}
