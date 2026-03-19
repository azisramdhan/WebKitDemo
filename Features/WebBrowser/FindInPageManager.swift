import UIKit
import WebKit

/// Integrates `WKFindInteraction` to provide an in-page search/find UI (iOS 16+).
///
/// Usage:
/// ```swift
/// let findManager = FindInPageManager(webView: webView)
/// findManager.showFindUI()  // shows the native find bar
/// findManager.search("webkit")
/// ```
@available(iOS 16.0, *)
public class FindInPageManager {
    
    private weak var webView: WKWebView?
    
    public init(webView: WKWebView) {
        self.webView = webView
        // Enable find interaction on the web view
        webView.isFindInteractionEnabled = true
    }
    
    // MARK: - Find UI
    
    /// Presents the native find navigator panel.
    public func showFindUI(showingReplace: Bool = false) {
        webView?.findInteraction?.presentFindNavigator(showingReplace: showingReplace)
    }
    
    /// Dismisses the find navigator panel.
    public func hideFindUI() {
        webView?.findInteraction?.dismissFindNavigator()
    }
    
    /// Programmatically sets the search text and triggers a search.
    public func search(_ query: String) {
        webView?.findInteraction?.searchText = query
    }
    
    /// Returns the current active search query (if any).
    public var currentQuery: String? {
        webView?.findInteraction?.searchText
    }
    
    /// Total number of results found (updated after search completes).
    public var resultCount: Int {
        webView?.findInteraction?.activeFindSession?.resultCount ?? 0
    }
    
    /// Index of the currently highlighted result (1-based).
    public var highlightedResultIndex: Int {
        webView?.findInteraction?.activeFindSession?.highlightedResultIndex ?? 0
    }
    
    /// Navigate to the next find result.
    public func findNext() {
        webView?.findInteraction?.findNext()
    }
    
    /// Navigate to the previous find result.
    public func findPrevious() {
        webView?.findInteraction?.findPrevious()
    }
}
