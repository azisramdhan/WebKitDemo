import XCTest
@testable import WebKitDemo

class JSMessageTests: XCTestCase {
    
    func testValidMessageParsing() {
        let dict: [String: Any] = [
            "action": "openNativeScreen",
            "data": ["screenName": "Profile"]
        ]
        
        let message = JSMessage(from: dict)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.action, "openNativeScreen")
        XCTAssertEqual(message?.data["screenName"] as? String, "Profile")
    }
    
    func testMissingActionFailsParsing() {
        let dict: [String: Any] = [
            "data": ["screenName": "Profile"]
        ]
        
        let message = JSMessage(from: dict)
        XCTAssertNil(message)
    }
    
    func testEmptyDataDefaultsToEmptyDict() {
        let dict: [String: Any] = [
            "action": "logoutUser"
        ]
        
        let message = JSMessage(from: dict)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.action, "logoutUser")
        XCTAssertTrue(message?.data.isEmpty ?? false)
    }
}
