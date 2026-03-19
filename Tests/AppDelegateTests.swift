import XCTest
import UIKit
@testable import WebKitDemo

final class AppDelegateTests: XCTestCase {
    
    func testAppDelegateCoverage() {
        let appDelegate = AppDelegate()
        
        // didFinishLaunching
        let launchResult = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertTrue(launchResult)
    }
}
