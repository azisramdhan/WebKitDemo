import XCTest
@testable import WebKitDemo

class SecurityValidatorTests: XCTestCase {
    
    var validator: SecurityValidator!
    
    override func setUp() {
        super.setUp()
        validator = SecurityValidator(allowedDomains: ["example.com", "secure.demo.com"])
    }
    
    func testAllowedDomains() {
        XCTAssertTrue(validator.isAllowedURL(URL(string: "https://example.com/login")))
        XCTAssertTrue(validator.isAllowedURL(URL(string: "https://sub.example.com")))
        XCTAssertTrue(validator.isAllowedURL(URL(string: "https://secure.demo.com/app")))
    }
    
    func testRejectedDomains() {
        XCTAssertFalse(validator.isAllowedURL(URL(string: "https://malicious.com")))
        XCTAssertFalse(validator.isAllowedURL(URL(string: "https://example.com.malicious.net")))
    }
    
    func testLocalSchemesAllowed() {
        XCTAssertTrue(validator.isAllowedURL(URL(string: "file:///local/path")))
        XCTAssertTrue(validator.isAllowedURL(URL(string: "about:blank")))
    }
    
    func testSafeNavigationSchemes() {
        XCTAssertTrue(validator.isSafeNavigationScheme("https"))
        XCTAssertTrue(validator.isSafeNavigationScheme("mailto"))
        XCTAssertTrue(validator.isSafeNavigationScheme("tel"))
        
        XCTAssertFalse(validator.isSafeNavigationScheme("custom-app-scheme"))
        XCTAssertFalse(validator.isSafeNavigationScheme("javascript"))
    }
}
