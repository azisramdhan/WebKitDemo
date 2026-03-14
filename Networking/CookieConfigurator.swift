import Foundation
import WebKit

public class CookieConfigurator {
    public static let shared = CookieConfigurator()
    
    private init() {}
    
    /// Synchronizes a given token into the WKHTTPCookieStore of a specific WKWebsiteDataStore
    public func injectAuthCookie(token: String, domain: String, dataStore: WKWebsiteDataStore, completion: @escaping () -> Void) {
        
        // Strip out protocol or custom paths if domain was passed as URL string
        var normalizedDomain = domain
        if let url = URL(string: domain), let host = url.host {
            normalizedDomain = host
        }
        
        let properties: [HTTPCookiePropertyKey: Any] = [
            .name: "auth_token",
            .value: token,
            .domain: normalizedDomain,
            .path: "/",
            .secure: "TRUE",
            .expires: Date(timeIntervalSinceNow: 3600 * 24 * 30) // 30 Days
        ]
        
        if let cookie = HTTPCookie(properties: properties) {
            dataStore.httpCookieStore.setCookie(cookie) {
                completion()
            }
        } else {
            completion()
        }
    }
}
