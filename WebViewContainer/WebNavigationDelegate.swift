import Foundation
import WebKit

public protocol WebNavigationObserver: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didFailLoading(error: Error)
    func openExternalLink(url: URL)
}

public class WebNavigationDelegate: NSObject, WKNavigationDelegate {
    
    public weak var observer: WebNavigationObserver?
    private let securityValidator: SecurityValidator
    
    public init(securityValidator: SecurityValidator) {
        self.securityValidator = securityValidator
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Check for safe schemes (e.g. mailto should open in native app, not webview)
        if !securityValidator.isSafeNavigationScheme(url.scheme) {
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
            return
        }
        
        // Handle target=_blank or links explicitly opened in new window/tab
        if navigationAction.targetFrame == nil {
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
            return
        }
        
        // Allowed domains check
        if securityValidator.isAllowedURL(url) {
            decisionHandler(.allow)
        } else {
            // If it's outside our application ecosystem, open in Safari instead to avoid phishing attacks
            observer?.openExternalLink(url: url)
            decisionHandler(.cancel)
        }
    }
    
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
