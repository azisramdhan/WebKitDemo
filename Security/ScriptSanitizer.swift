import Foundation

public class ScriptSanitizer {
    
    /// Escapes strings before injecting them into evaluateJavaScript to prevent injection attacks
    /// or syntax breaking characters when generating javascript strings natively.
    public static func sanitizeForJSString(_ input: String) -> String {
        return input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }
}
