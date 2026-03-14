import Foundation

public struct AppConfiguration {
    public static let shared = AppConfiguration()
    
    // Environment configurations
    public let baseAppHost = "example.com"
    public let secureHostWhitelist: [String] = ["example.com", "m.example.com", "localhost"]
    public let appName = "WebKitDemo"
    
    private init() {}
}
