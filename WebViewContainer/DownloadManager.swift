import Foundation
import WebKit

/// Handles WKDownloadDelegate callbacks for file downloads triggered by the web view (iOS 15+).
///
/// Usage: set as `webView.navigationDelegate` and assign as download delegate
/// when `decidePolicyFor` receives a `.download` response.
///
/// ```swift
/// func webView(_ webView: WKWebView,
///              navigationResponse: WKNavigationResponse,
///              didBecome download: WKDownload) {
///     download.delegate = DownloadManager.shared
/// }
/// ```
@available(iOS 15.0, *)
public class DownloadManager: NSObject, WKDownloadDelegate {
    
    public static let shared = DownloadManager()
    private override init() {}
    
    public var onProgress: ((Double) -> Void)?
    public var onComplete: ((URL) -> Void)?
    public var onFailure: ((Error) -> Void)?
    
    private var destinationURL: URL?
    
    // MARK: - WKDownloadDelegate
    
    public func download(_ download: WKDownload,
                         decideDestinationUsing response: URLResponse,
                         suggestedFilename: String,
                         completionHandler: @escaping (URL?) -> Void) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(suggestedFilename)
        
        // Remove existing file so download doesn't fail
        try? FileManager.default.removeItem(at: dest)
        
        destinationURL = dest
        completionHandler(dest)
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        if let url = destinationURL {
            DispatchQueue.main.async {
                self.onComplete?(url)
            }
        }
    }
    
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        DispatchQueue.main.async {
            self.onFailure?(error)
        }
    }
    
    public func download(_ download: WKDownload,
                         didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}
