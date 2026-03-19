import XCTest
@testable import WebKitDemo

final class LegacyWebViewControllerTests: XCTestCase {
    
    func testViewDidLoad() {
        let vc = LegacyWebViewController()
        
        // Trigger viewDidLoad
        XCTAssertNotNil(vc.view)
        
        XCTAssertEqual(vc.title, "Legacy UIWebView Info")
        XCTAssertEqual(vc.view.backgroundColor, .systemBackground)
        XCTAssertEqual(vc.view.subviews.count, 1) // Should have one UILabel
        
        let label = vc.view.subviews.first as? UILabel
        XCTAssertNotNil(label)
        XCTAssertEqual(label?.textAlignment, .center)
        XCTAssertEqual(label?.numberOfLines, 0)
    }
}
