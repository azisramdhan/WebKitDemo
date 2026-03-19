import UIKit
import WebKit

/// Handles `WKUIDelegate` callbacks: JavaScript dialogs and new window creation.
///
/// Assign this as `webView.uiDelegate` to intercept:
/// - `alert()`, `confirm()`, `prompt()` JS dialogs
/// - `window.open()` / `target=_blank` new windows
public class WebUIDelegate: NSObject, WKUIDelegate {
    
    public weak var presentingViewController: UIViewController?
    
    public init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    // MARK: - JavaScript Dialogs
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: webView.url?.host ?? "Alert",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        presentingViewController?.present(alert, animated: true)
    }
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: webView.url?.host ?? "Confirm",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        presentingViewController?.present(alert, animated: true)
    }
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: webView.url?.host ?? "Prompt",
                                      message: prompt,
                                      preferredStyle: .alert)
        alert.addTextField { tf in tf.text = defaultText }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        presentingViewController?.present(alert, animated: true)
    }
    
    // MARK: - New Window (target=_blank / window.open)
    
    /// Instead of opening a new WKWebView window, we navigate the existing webView to the URL.
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        // target=_blank links — load in the same webview
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}
