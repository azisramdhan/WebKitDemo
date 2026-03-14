import XCTest

class WebKitDemoUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testLoginFlowAndWebLoad() throws {
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]
        
        XCTAssertTrue(usernameField.exists)
        XCTAssertTrue(passwordField.exists)
        
        usernameField.tap()
        usernameField.typeText("admin")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        loginButton.tap()
        
        // Wait for WKWebView to emerge
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5.0))
    }
    
    func testLocalHTMLDemo() throws {
        let localDemoButton = app.buttons["Skip to Local HTML Demo"]
        XCTAssertTrue(localDemoButton.exists)
        
        localDemoButton.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 3.0))
    }
}
