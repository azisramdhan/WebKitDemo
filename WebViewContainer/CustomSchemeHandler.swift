import Foundation
import WebKit

/// Intercepts requests for the custom `wkdemo://` URL scheme and serves mock responses.
///
/// Register via: `configuration.setURLSchemeHandler(CustomSchemeHandler(), forURLScheme: "wkdemo")`
///
/// Example URLs this handles:
/// - `wkdemo://api/user` → returns mock JSON
/// - `wkdemo://asset/logo.png` → could return bundled assets
public class CustomSchemeHandler: NSObject, WKURLSchemeHandler {
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url,
              let host = url.host else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }
        
        let responseBody: Data
        let mimeType: String
        
        switch host {
        case "api":
            let path = url.path
            let json: [String: Any]
            
            switch path {
            case "/user":
                json = ["id": 1, "name": "Demo User", "role": "admin"]
            case "/config":
                json = ["theme": "dark", "version": "1.0.0", "featureFlags": ["bridge": true]]
            default:
                json = ["error": "Unknown endpoint: \(path)"]
            }
            
            responseBody = (try? JSONSerialization.data(withJSONObject: json)) ?? Data()
            mimeType = "application/json"
            
        default:
            let html = "<html><body><p>wkdemo://\(host)\(url.path)</p></body></html>"
            responseBody = html.data(using: .utf8) ?? Data()
            mimeType = "text/html"
        }
        
        let response = URLResponse(url: url,
                                   mimeType: mimeType,
                                   expectedContentLength: responseBody.count,
                                   textEncodingName: "utf-8")
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(responseBody)
        urlSchemeTask.didFinish()
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // No-op: tasks are synchronous in this demo
    }
}
