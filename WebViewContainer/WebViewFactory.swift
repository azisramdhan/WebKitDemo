import Foundation
import WebKit

public class WebViewFactory {
    
    // MARK: - Shared Process Pool (Feature 9: WKProcessPool)
    
    /// Shared process pool to maintain common cookies, caching, and local storage across web views.
    /// Multiple WKWebViews sharing this pool can access each other's session cookies without
    /// additional cookie injection — critical for multi-view apps (e.g. modal + main browser).
    public static let sharedProcessPool = WKProcessPool()
    
    // MARK: - Custom User Agent (Feature 11)
    
    /// The default custom user agent appended to the system UA.
    /// Format: `<system UA> WebKitDemo/1.0 (iOS)`
    public static let customUserAgentSuffix = "WebKitDemo/1.0 (iOS)"
    
    // MARK: - Factory Method
    
    /// Creates a fully configured WKWebView with all production settings applied:
    /// - Shared WKProcessPool
    /// - Custom User Agent
    /// - Media playback (inline, autoplay, AirPlay)
    /// - WKWebpagePreferences
    /// - JS bridge registration
    /// - Custom URL scheme handler (wkdemo://)
    /// - WKContentRuleList (content blocking, applied async)
    public static func createWebView(
        scriptMessageHandler: WKScriptMessageHandler,
        bridgeName: String = "nativeBridge",
        enableContentBlocking: Bool = true
    ) -> WKWebView {
        
        // MARK: WKWebpagePreferences (Feature 10)
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        // .mobile keeps layout optimized for iOS, .desktop shows the desktop site
        pagePrefs.preferredContentMode = .mobile
        
        // MARK: WKWebViewConfiguration
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = pagePrefs
        
        // Feature 9: Shared process pool
        config.processPool = sharedProcessPool
        
        // MARK: Media Playback (Feature 12)
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []  // autoplay allowed
        config.allowsAirPlayForMediaPlayback = true
        
        // MARK: Custom URL Scheme (Feature 2)
        config.setURLSchemeHandler(CustomSchemeHandler(), forURLScheme: "wkdemo")
        
        // MARK: JS Bridge
        let contentController = WKUserContentController()
        contentController.add(scriptMessageHandler, name: bridgeName)
        
        // Async bridge (Feature 5, iOS 14+)
        if #available(iOS 14.0, *) {
            contentController.addScriptMessageHandler(
                AsyncJSBridgeManager.shared,
                contentWorld: .page,
                name: "asyncBridge"
            )
        }
        
        config.userContentController = contentController
        
        // Legacy preferences
        let legacyPrefs = WKPreferences()
        legacyPrefs.javaScriptCanOpenWindowsAutomatically = false
        config.preferences = legacyPrefs
        
        // MARK: WKWebView
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        
        // Feature 11: Custom User Agent
        // We read the default UA first and append our suffix
        webView.evaluateJavaScript("navigator.userAgent") { result, _ in
            if let systemUA = result as? String {
                webView.customUserAgent = "\(systemUA) \(customUserAgentSuffix)"
            }
        }
        
        // Safari Web Inspector (iOS 16.4+)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        // Feature 13: Find-in-Page (iOS 16+)
        if #available(iOS 16.0, *) {
            webView.isFindInteractionEnabled = true
        }
        
        // Feature 3: Content Blocking (async — applied after compilation)
        if enableContentBlocking {
            ContentBlockingManager.shared.install(into: config) { result in
                if case .failure(let error) = result {
                    print("[WebViewFactory] Content blocking install failed: \(error.localizedDescription)")
                }
            }
        }
        
        return webView
    }
    
    // MARK: - callAsyncJavaScript helper (Feature 6, iOS 14+)
    
    /// Evaluates JavaScript using the modern `callAsyncJavaScript` API.
    /// Unlike `evaluateJavaScript`, this properly passes Swift values as typed JS arguments
    /// and supports async/await semantics in the JS script itself.
    ///
    /// Example:
    /// ```swift
    /// WebViewFactory.callAsync(in: webView,
    ///     script: "return await fetchUser(userId)",
    ///     arguments: ["userId": 42]) { result in
    ///         print(result)
    /// }
    /// ```
    @available(iOS 14.0, *)
    public static func callAsync(in webView: WKWebView,
                                 script: String,
                                 arguments: [String: Any] = [:],
                                 completion: @escaping (Result<Any, Error>) -> Void) {
        webView.callAsyncJavaScript(
            script,
            arguments: arguments,
            in: nil,
            in: .page
        ) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
