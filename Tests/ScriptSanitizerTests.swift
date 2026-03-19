import XCTest
@testable import WebKitDemo

final class ScriptSanitizerTests: XCTestCase {
    
    func testSanitizeForJSString() {
        let input = "This is a test with \\ (backslash), \" (double quote), ' (single quote), \n (newline), and \r (carriage return)."
        let expected = "This is a test with \\\\ (backslash), \\\" (double quote), \\' (single quote), \\n (newline), and \\r (carriage return)."
        
        let result = ScriptSanitizer.sanitizeForJSString(input)
        
        XCTAssertEqual(result, expected, "Sanitizer failed to properly escape JS breaking characters.")
    }
    
    func testSanitizeEmptyString() {
        XCTAssertEqual(ScriptSanitizer.sanitizeForJSString(""), "")
    }
}
