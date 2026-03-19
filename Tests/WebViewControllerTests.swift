import XCTest
@testable import WebKitDemo

class MockWebViewModel: WebViewModel {
    var startCalled = false
    var logoutRequested = false
    
    init() {
        super.init(startURL: URL(string: "about:blank")!)
    }
    
    override func start() {
        startCalled = true
    }
    
    override func requestLogout() {
        logoutRequested = true
    }
}

final class WebViewControllerTests: XCTestCase {
    
    var viewModel: MockWebViewModel!
    var viewController: WebViewController!
    
    override func setUp() {
        super.setUp()
        viewModel = MockWebViewModel()
        viewController = WebViewController(viewModel: viewModel)
        // Trigger view load
        _ = viewController.view
    }
    
    func testViewDidLoadTriggersViewModelStart() {
        XCTAssertTrue(viewModel.startCalled)
        XCTAssertNotNil(viewController.navigationItem.rightBarButtonItem)
        XCTAssertNotNil(viewController.navigationItem.leftBarButtonItem)
    }
    
    func testNavigationObserverMethods() {
        viewController.didStartLoading()
        // verify progress
        viewController.didUpdateProgress(0.5)
        viewController.didFinishLoading()
    }
    
    func testShowToast() {
        viewController.showToast("Test Toast")
        // No crash
    }
    
    func testHandleOpenNativeScreen() {
        viewController.handleOpenNativeScreen(screenName: "Profile", params: [:])
        
        let expectation = XCTestExpectation(description: "alert presentation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleLogout() {
        viewController.handleLogout()
        XCTAssertTrue(viewModel.logoutRequested)
    }
    
    func testHandleRequestNativeData() {
        viewController.handleRequestNativeData(callbackId: "123")
        let expectation = XCTestExpectation(description: "js evaluation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWebViewModelDelegateMethods() {
        viewController.showError("Error message")
        viewController.performLogout()
        viewController.loadURL(URL(string: "https://example.com")!)
    }
}
