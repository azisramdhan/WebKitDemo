import Foundation
import WebKit

/// Wraps `WKBackForwardList` to provide convenient back/forward navigation.
///
/// Usage:
/// ```swift
/// let navigator = BackForwardNavigator(webView: webView)
/// navigator.goBack()
/// navigator.goForward()
/// print(navigator.backItemCount)  // e.g. 3
/// ```
public class BackForwardNavigator {
    
    private weak var webView: WKWebView?
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - State
    
    public var canGoBack: Bool {
        webView?.canGoBack ?? false
    }
    
    public var canGoForward: Bool {
        webView?.canGoForward ?? false
    }
    
    /// Number of pages in the back list (not counting current page).
    public var backItemCount: Int {
        webView?.backForwardList.backList.count ?? 0
    }
    
    /// Number of pages in the forward list.
    public var forwardItemCount: Int {
        webView?.backForwardList.forwardList.count ?? 0
    }
    
    public var currentItem: WKBackForwardListItem? {
        webView?.backForwardList.currentItem
    }
    
    public var backList: [WKBackForwardListItem] {
        webView?.backForwardList.backList ?? []
    }
    
    public var forwardList: [WKBackForwardListItem] {
        webView?.backForwardList.forwardList ?? []
    }
    
    // MARK: - Navigation
    
    @discardableResult
    public func goBack() -> WKNavigation? {
        webView?.goBack()
    }
    
    @discardableResult
    public func goForward() -> WKNavigation? {
        webView?.goForward()
    }
    
    /// Navigate to a specific item in the back/forward list.
    @discardableResult
    public func go(to item: WKBackForwardListItem) -> WKNavigation? {
        webView?.go(to: item)
    }
    
    /// Navigate back by `steps` pages (clamped to available back list).
    @discardableResult
    public func goBack(steps: Int) -> WKNavigation? {
        let list = backList
        let index = min(steps, list.count) - 1
        guard index >= 0 else { return nil }
        return go(to: list[list.count - 1 - index])
    }
    
    /// Returns a summary of the full history for debugging.
    public func historySummary() -> String {
        let back = backList.map { $0.url.absoluteString }
        let current = currentItem?.url.absoluteString ?? "(none)"
        let fwd = forwardList.map { $0.url.absoluteString }
        return "Back: \(back) | Current: \(current) | Forward: \(fwd)"
    }
}
