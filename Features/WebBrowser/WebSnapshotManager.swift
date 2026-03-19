import UIKit
import WebKit

/// Captures screenshots and generates PDFs from a `WKWebView`.
///
/// Usage:
/// ```swift
/// let manager = WebSnapshotManager(webView: webView)
/// manager.takeSnapshot { image in
///     imageView.image = image
/// }
/// manager.exportPDF { data in
///     // save or share data
/// }
/// ```
@available(iOS 14.0, *)
public class WebSnapshotManager {
    
    private weak var webView: WKWebView?
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - Screenshot
    
    /// Captures the currently visible area of the web view as a `UIImage`.
    public func takeSnapshot(completion: @escaping (UIImage?) -> Void) {
        guard let webView = webView else {
            completion(nil)
            return
        }
        
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(origin: .zero, size: webView.frame.size)
        config.afterScreenUpdates = true
        
        webView.takeSnapshot(with: config) { image, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[WebSnapshotManager] Snapshot error: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(image)
                }
            }
        }
    }
    
    // MARK: - PDF Export
    
    /// Exports the full content of the web view to a PDF `Data` object.
    public func exportPDF(completion: @escaping (Data?) -> Void) {
        guard let webView = webView else {
            completion(nil)
            return
        }
        
        let config = WKPDFConfiguration()
        config.rect = CGRect(origin: .zero, size: webView.scrollView.contentSize)
        
        webView.createPDF(configuration: config) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    print("[WebSnapshotManager] PDF error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Save to disk
    
    /// Saves a snapshot to the app's Documents directory and returns the file URL.
    public func saveSnapshotToDisk(filename: String = "snapshot.png",
                                   completion: @escaping (URL?) -> Void) {
        takeSnapshot { image in
            guard let image = image, let data = image.pngData() else {
                completion(nil)
                return
            }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = docs.appendingPathComponent(filename)
            do {
                try data.write(to: url)
                completion(url)
            } catch {
                print("[WebSnapshotManager] Save error: \(error)")
                completion(nil)
            }
        }
    }
}
