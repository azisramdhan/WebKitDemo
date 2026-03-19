import XCTest
import WebKit
@testable import WebKitDemo

final class CookieConfiguratorTests: XCTestCase {
    
    func testInjectAuthCookieSuccess() {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let expectation = XCTestExpectation(description: "Cookie injected")
        
        CookieConfigurator.shared.injectAuthCookie(token: "test_token", domain: "example.com", dataStore: dataStore) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch cookie")
        dataStore.httpCookieStore.getAllCookies { cookies in
            let authCookie = cookies.first { $0.name == "auth_token" }
            XCTAssertNotNil(authCookie)
            XCTAssertEqual(authCookie?.value, "test_token")
            XCTAssertEqual(authCookie?.domain, "example.com")
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 5.0)
    }
    
    func testInjectAuthCookieWithFullURL() {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let expectation = XCTestExpectation(description: "Cookie injected via full URL")
        
        CookieConfigurator.shared.injectAuthCookie(token: "token2", domain: "https://auth.example.com/login", dataStore: dataStore) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch cookie via full URL domain parsing")
        dataStore.httpCookieStore.getAllCookies { cookies in
            let authCookie = cookies.first { $0.name == "auth_token" && $0.value == "token2" }
            XCTAssertNotNil(authCookie)
            XCTAssertEqual(authCookie?.domain, "auth.example.com")
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 5.0)
    }
    
    func testInjectAuthCookieInvalidDomain() {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let expectation = XCTestExpectation(description: "Cookie fails gracefully")
        
        CookieConfigurator.shared.injectAuthCookie(token: "valid", domain: "", dataStore: dataStore) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
