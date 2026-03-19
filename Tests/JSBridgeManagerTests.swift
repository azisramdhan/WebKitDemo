import XCTest
import WebKit
@testable import WebKitDemo

// Mock Delegate
class MockJSBridgeDelegate: JSBridgeDelegate {
    var openedScreenName: String?
    var openedScreenParams: [String: Any]?
    var shownToastMessage: String?
    var requestedCallbackId: String?
    var logoutCalled = false
    
    func handleOpenNativeScreen(screenName: String, params: [String: Any]) {
        self.openedScreenName = screenName
        self.openedScreenParams = params
    }
    
    func handleShowToast(message: String) {
        self.shownToastMessage = message
    }
    
    func handleRequestNativeData(callbackId: String) {
        self.requestedCallbackId = callbackId
    }
    
    func handleLogout() {
        self.logoutCalled = true
    }
}

// Mock WKScriptMessage
class MockWKScriptMessage: WKScriptMessage {
    let mockName: String
    let mockBody: Any
    
    init(name: String, body: Any) {
        self.mockName = name
        self.mockBody = body
        super.init()
    }
    
    override var name: String {
        return mockName
    }
    
    override var body: Any {
        return mockBody
    }
}

final class JSBridgeManagerTests: XCTestCase {
    
    var manager: JSBridgeManager!
    var mockDelegate: MockJSBridgeDelegate!
    var userContentController: WKUserContentController!
    
    override func setUp() {
        super.setUp()
        manager = JSBridgeManager()
        mockDelegate = MockJSBridgeDelegate()
        manager.delegate = mockDelegate
        userContentController = WKUserContentController()
    }
    
    func testInvalidMessageFormat() {
        // Not a dictionary body
        let msg = MockWKScriptMessage(name: "nativeBridge", body: "StringBody")
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertNil(mockDelegate.openedScreenName)
    }
    
    func testInvalidBridgeName() {
        // Wrong handler name
        let body: [String: Any] = ["action": "logoutUser"]
        let msg = MockWKScriptMessage(name: "wrongBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertFalse(mockDelegate.logoutCalled)
    }
    
    func testOpenNativeScreenAction() {
        let body: [String: Any] = [
            "action": "openNativeScreen",
            "data": ["screenName": "Profile"]
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertEqual(mockDelegate.openedScreenName, "Profile")
    }
    
    func testShowToastAction() {
        let body: [String: Any] = [
            "action": "showToast",
            "data": ["message": "Hello"]
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertEqual(mockDelegate.shownToastMessage, "Hello")
    }
    
    func testRequestNativeDataAction() {
        let body: [String: Any] = [
            "action": "requestNativeData",
            "data": ["callbackId": "123"]
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertEqual(mockDelegate.requestedCallbackId, "123")
    }
    
    func testLogoutUserAction() {
        let body: [String: Any] = [
            "action": "logoutUser"
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertTrue(mockDelegate.logoutCalled)
    }
    
    func testUnknownAction() {
        let body: [String: Any] = [
            "action": "unknownAction"
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        
        // Ensure it handles gracefully
        manager.userContentController(userContentController, didReceive: msg)
        
        XCTAssertNil(mockDelegate.openedScreenName)
        XCTAssertFalse(mockDelegate.logoutCalled)
    }
    
    func testInvalidJSMessageFormat() {
        let msg = MockWKScriptMessage(name: "nativeBridge", body: ["wrong": "format"])
        manager.userContentController(userContentController, didReceive: msg)
    }
    
    func testNilDelegate() {
        manager.delegate = nil
        let body: [String: Any] = [
            "action": "logoutUser"
        ]
        let msg = MockWKScriptMessage(name: "nativeBridge", body: body)
        manager.userContentController(userContentController, didReceive: msg)
        // No crash
    }
}



