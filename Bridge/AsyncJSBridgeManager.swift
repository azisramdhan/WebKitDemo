import Foundation
import WebKit

/// Two-way async bridge using `WKScriptMessageHandlerWithReply` (iOS 14+).
///
/// JavaScript side:
/// ```js
/// const result = await window.webkit.messageHandlers.asyncBridge.postMessage({
///     action: "getNativeData",
///     key: "userProfile"
/// });
/// console.log(result.name); // "Demo User"
/// ```
///
/// Register with:
/// ```swift
/// configuration.userContentController.addScriptMessageHandler(
///     AsyncJSBridgeManager.shared, contentWorld: .page, name: "asyncBridge"
/// )
/// ```
@available(iOS 14.0, *)
public class AsyncJSBridgeManager: NSObject, WKScriptMessageHandlerWithReply {
    
    public static let shared = AsyncJSBridgeManager()
    private override init() {}
    
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage,
                                      replyHandler: @escaping (Any?, String?) -> Void) {
        guard message.name == "asyncBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            replyHandler(nil, "Invalid message format")
            return
        }
        
        switch action {
        case "getNativeData":
            let key = body["key"] as? String ?? "unknown"
            let response = handleGetNativeData(key: key)
            replyHandler(response, nil)
            
        case "getAppVersion":
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            replyHandler(["version": version], nil)
            
        case "getDeviceInfo":
            let info: [String: Any] = [
                "model": UIDevice.current.model,
                "systemVersion": UIDevice.current.systemVersion,
                "name": UIDevice.current.name
            ]
            replyHandler(info, nil)
            
        default:
            replyHandler(nil, "Unknown async bridge action: \(action)")
        }
    }
    
    // MARK: - Private Handlers
    
    private func handleGetNativeData(key: String) -> [String: Any] {
        switch key {
        case "userProfile":
            return ["id": 1, "name": "Demo User", "role": "admin", "email": "demo@example.com"]
        case "settings":
            return ["theme": "dark", "language": "en", "notifications": true]
        default:
            return ["error": "No data for key: \(key)"]
        }
    }
}

import UIKit
