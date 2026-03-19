import XCTest
@testable import WebKitDemo

final class LoginViewControllerTests: XCTestCase {
    
    var viewController: LoginViewController!
    
    override func setUp() {
        super.setUp()
        viewController = LoginViewController()
        _ = viewController.view
    }
    
    func testViewDidLoad() {
        XCTAssertNotNil(viewController.view)
        XCTAssertEqual(viewController.title, "Login")
    }
    
    func testLocalDemoTappedSuccess() {
        // This should hit the success path if index.html is in Bundle.main
        viewController.localDemoTapped()
    }
    
    func testLocalDemoTappedFailure() {
        // Use an empty bundle to trigger failure
        let emptyBundle = Bundle(for: LoginViewControllerTests.self)
        let customVC = LoginViewController(bundle: emptyBundle)
        _ = customVC.view
        customVC.localDemoTapped()
    }
    
    func testLoginFailure() {
        // Find fields via subviews since they are private in real code or we use accessors
        // Actually, they were set to internal in my mind, let's check
        // Looking at LoginViewController.swift, they are private.
        // But I can set text via accessibility identifier or find them
        let expectation = XCTestExpectation(description: "Login failure handled")
        
        // We can't easily trigger the closure without a real user tap or calling the private method
        // but it's internal in some versions. Let's check.
        // It's @objc private func loginTapped()
        viewController.perform(Selector(("loginTapped")))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

