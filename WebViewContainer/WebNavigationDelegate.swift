import Foundation
import WebKit

public protocol WebNavigationObserver: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didFailLoading(error: Error)
    func openExternalLink(url: URL)
}

/// Handles `WKNavigationDelegate` callbacks for navigation policy, loading events,
/// and per-navigation `WKWebpagePreferences` (Feature 10).
public class WebNavigationDelegate: NSObject, WKNavigationDelegate {
    
    public weak var observer: WebNavigationObserver?
    private let securityValidator: SecurityValidator
    
    /// When true, the next navigation will request the desktop site.
    public var preferDesktopSite: Bool = false
    
    public init(securityValidator: SecurityValidator) {
        self.securityValidator = securityValidator
    }
    
    // MARK: - Policy + WKWebpagePreferences (Feature 10)
    
    /// iOS 14+ override that allows per-navigation preference control.
    @available(iOS 14.0, *)
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        preferences: WKWebpagePreferences,
                        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        // Apply desktop/mobile preference dynamically
        preferences.preferredContentMode = preferDesktopSite ? .desktop : .mobile
        preferences.allowsContentJavaScript = true
        
        // Reuse the existing URL-check logic
        let url = navigationAction.request.url
        let isNewWindow = navigationAction.targetFrame == nil
        
        decidePolicyCore(for: url, isNewWindow: isNewWindow) { policy in
            decisionHandler(policy, preferences)
        }
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decidePolicy(for: navigationAction.request.url,
                     isNewWindow: navigationAction.targetFrame == nil,
                     decisionHandler: decisionHandler)
    }
    
    // MARK: - Core decision logic
    
    /// Internal method for unit testing without WKNavigationAction or WKFrameInfo.
    internal func decidePolicy(for url: URL?, isNewWindow: Bool, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decidePolicyCore(for: url, isNewWindow: isNewWindow, decisionHandler: decisionHandler)
    }
    
    private func decidePolicyCore(for url: URL?, isNewWindow: Bool, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = url else {
            decisionHandler(.cancel)
            return
        }
        
        // Check for safe schemes (e.g. mailto: should open in native app, not webview)
        if !securityValidator.isSafeNavigationScheme(url.scheme) {
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
            return
        }
        
        // Handle target=_blank or links explicitly opened in new window/tab
        if isNewWindow {
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
            return
        }
        
        // Allowed domains check
        if securityValidator.isAllowedURL(url) {
            decisionHandler(.allow)
        } else {
            // Outside our app ecosystem — open in Safari to avoid phishing
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
        }
    }
    
    // MARK: - Loading Events
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        observer?.didStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        observer?.didFinishLoading()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        // Ignore deliberate cancellations (e.g. fast navigations)
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        observer?.didFailLoading(error: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        observer?.didFailLoading(error: error)
    }
}
