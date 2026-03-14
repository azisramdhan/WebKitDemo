import Foundation

public class SecurityValidator {
    
    private let allowedDomains: [String]
    
    public init(allowedDomains: [String]) {
        self.allowedDomains = allowedDomains
    }
    
    /// Validates if a URL is allowed to be loaded by the WKWebView
    public func isAllowedURL(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        // Always allow local schemas
        if let scheme = url.scheme?.lowercased(), ["file", "about"].contains(scheme) {
            return true
        }
        
        guard let host = url.host?.lowercased() else { return false }
        
        return allowedDomains.contains { allowedDomain in
            let lowerAllowed = allowedDomain.lowercased()
            return host == lowerAllowed || host.hasSuffix("." + lowerAllowed)
        }
    }
    
    /// Evaluates navigation policies based on scheme
    public func isSafeNavigationScheme(_ scheme: String?) -> Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return ["http", "https", "file", "about", "mailto", "tel"].contains(scheme)
    }
}
