import UIKit
import WebKit

/// This class demonstrates the historical usage of UIWebView (which is deprecated and removed in iOS 12+).
/// As UIWebView is no longer available in modern SDKs, we use comments to illustrate the implementation pattern
/// and how it fundamentally migrated to WKWebView architecture.
public class LegacyWebViewController: UIViewController {
    
    /*
    // MARK: - Legacy UIWebView Implementation (Pre-iOS 12)
    
    private var uiWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Initialization
        // Old: uiWebView = UIWebView(frame: view.bounds)
        // New: webView = WKWebView(frame: view.bounds, configuration: config)
        
        // 2. JS Evaluation
        // Old: a blocking synchronous call on the main thread
        //      let result = uiWebView.stringByEvaluatingJavaScript(from: "document.title")
        // New: an async, non-blocking call
        //      webView.evaluateJavaScript("document.title") { result, error in ... }
        
        // 3. Delegation
        // Old: uiWebView.delegate = self
        // New: webView.navigationDelegate = self; webView.uiDelegate = self
        
        // 4. Loading content
        // Old: uiWebView.loadRequest(URLRequest(url: url))
        // New: webView.load(URLRequest(url: url))
        
        // 5. JavaScript Bridging
        // Old: Hacky URL interception inside `shouldStartLoadWith` delegate
        // New: First-class `WKScriptMessageHandler` via `WKUserContentController`
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        // Used for intercepting custom URL schemes as a primitive JS bridge
        // if request.url?.scheme == "mybridge" { process(...) ; return false }
        return true
    }
    */
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Legacy UIWebView Info"
        
        let label = UILabel()
        label.text = "This module serves as documentation for UIWebView behavior.\n\nPlease review the LegacyWebViewController.swift source code to see exactly how UIWebView patterns transition linearly into modern WKWebView paradigms."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
