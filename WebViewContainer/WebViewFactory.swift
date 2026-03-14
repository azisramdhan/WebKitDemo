import Foundation
import WebKit

public class WebViewFactory {
    
    /// Shared process pool to maintain common cookies, caching, and local storage across web views
    /// This drastically improves performance and reduces memory footprint for multi-webview apps.
    public static let sharedProcessPool = WKProcessPool()
    
    public static func createWebView(scriptMessageHandler: WKScriptMessageHandler, withBridgeName bridgeName: String = "nativeBridge") -> WKWebView {
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.processPool = sharedProcessPool
        
        let contentController = WKUserContentController()
        // Register the JS bridge message handler
        contentController.add(scriptMessageHandler, name: bridgeName)
        
        config.userContentController = contentController
        
        // Legacy preferences configuration
        let legacyPrefs = WKPreferences()
        legacyPrefs.javaScriptCanOpenWindowsAutomatically = false
        config.preferences = legacyPrefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        
        // Enable inspection in supported iOS versions for Safari Web Inspector
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        return webView
    }
}
