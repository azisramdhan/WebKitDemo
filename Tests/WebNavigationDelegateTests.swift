import XCTest
import WebKit
@testable import WebKitDemo

class MockWebNavigationObserver: WebNavigationObserver {
    var didStartCalled = false
    var didFinishCalled = false
    var didFailError: Error?
    var openedExtURL: URL?
    
    func didStartLoading() {
        didStartCalled = true
    }
    
    func didFinishLoading() {
        didFinishCalled = true
    }
    
    func didFailLoading(error: Error) {
        didFailError = error
    }
    
    func openExternalLink(url: URL) {
        openedExtURL = url
    }
}

final class WebNavigationDelegateTests: XCTestCase {
    
    var delegate: WebNavigationDelegate!
    var mockObserver: MockWebNavigationObserver!
    var webView: WKWebView!
    
    override func setUp() {
        super.setUp()
        let config = AppConfiguration.shared
        let validator = SecurityValidator(allowedDomains: config.secureHostWhitelist)
        delegate = WebNavigationDelegate(securityValidator: validator)
        mockObserver = MockWebNavigationObserver()
        delegate.observer = mockObserver
        webView = WKWebView()
    }
    
    func testDidFailProvisionalNavigation() {
        let nsError = NSError(domain: "TestDomain", code: 500, userInfo: nil)
        delegate.webView(webView, didFailProvisionalNavigation: nil, withError: nsError)
        
        XCTAssertNotNil(mockObserver.didFailError)
        XCTAssertEqual((mockObserver.didFailError as NSError?)?.code, 500)
    }
    
    func testDidFailProvisionalNavigationCancelledIgnored() {
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        delegate.webView(webView, didFailProvisionalNavigation: nil, withError: nsError)
        
        XCTAssertNil(mockObserver.didFailError)
    }
    
    func testDidFailNavigation() {
        let nsError = NSError(domain: "TestDomain", code: 404, userInfo: nil)
        delegate.webView(webView, didFail: nil, withError: nsError)
        
        XCTAssertNotNil(mockObserver.didFailError)
        XCTAssertEqual((mockObserver.didFailError as NSError?)?.code, 404)
    }
    
    func testDidStartProvisionalNavigation() {
        delegate.webView(webView, didStartProvisionalNavigation: nil)
        XCTAssertTrue(mockObserver.didStartCalled)
    }
    
    func testDidFinishNavigation() {
        delegate.webView(webView, didFinish: nil)
        XCTAssertTrue(mockObserver.didFinishCalled)
    }
    
    func testDecidePolicyNilURL() {
        var policy: WKNavigationActionPolicy?
        delegate.decidePolicy(for: nil, isNewWindow: false) { policy = $0 }
        XCTAssertEqual(policy, .cancel)
    }
    
    func testDecidePolicySafeScheme() {
        let url = URL(string: "https://example.com")!
        var policy: WKNavigationActionPolicy?
        delegate.decidePolicy(for: url, isNewWindow: false) { policy = $0 }
        XCTAssertEqual(policy, .allow)
    }
    
    func testDecidePolicyUnsafeScheme() {
        let url = URL(string: "custom://scheme")!
        var policy: WKNavigationActionPolicy?
        delegate.decidePolicy(for: url, isNewWindow: false) { policy = $0 }
        XCTAssertEqual(policy, .cancel)
        XCTAssertEqual(mockObserver.openedExtURL, url)
    }
    
    func testDecidePolicyBlankTarget() {
        let url = URL(string: "https://example.com")!
        var policy: WKNavigationActionPolicy?
        delegate.decidePolicy(for: url, isNewWindow: true) { policy = $0 }
        XCTAssertEqual(policy, .cancel)
        XCTAssertEqual(mockObserver.openedExtURL, url)
    }
    
    func testDecidePolicyDisallowedURL() {
        let url = URL(string: "https://malicious.com")!
        var policy: WKNavigationActionPolicy?
        delegate.decidePolicy(for: url, isNewWindow: false) { policy = $0 }
        XCTAssertEqual(policy, .cancel)
        XCTAssertEqual(mockObserver.openedExtURL, url)
    }
}


