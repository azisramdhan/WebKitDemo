import Foundation
import WebKit

/// Compiles and installs a `WKContentRuleList` to block ads and trackers.
///
/// Usage:
/// ```swift
/// ContentBlockingManager.shared.install(into: configuration) { result in
///     // configuration now has blocking rules applied
/// }
/// ```
public class ContentBlockingManager {
    
    public static let shared = ContentBlockingManager()
    private init() {}
    
    /// Basic content blocking rules — blocks common ad/tracker hosts and resource types.
    private let blockingRules: [[String: Any]] = [
        // Block third-party scripts from ad networks
        [
            "trigger": [
                "url-filter": ".*doubleclick\\.net.*",
                "load-type": ["third-party"]
            ],
            "action": ["type": "block"]
        ],
        [
            "trigger": [
                "url-filter": ".*googlesyndication\\.com.*",
                "load-type": ["third-party"]
            ],
            "action": ["type": "block"]
        ],
        [
            "trigger": [
                "url-filter": ".*googletagmanager\\.com.*",
                "load-type": ["third-party"]
            ],
            "action": ["type": "block"]
        ],
        [
            "trigger": [
                "url-filter": ".*facebook\\.net/en_US/fbevents\\.js"
            ],
            "action": ["type": "block"]
        ],
        // Block tracking pixels (1x1 images from analytics domains)
        [
            "trigger": [
                "url-filter": ".*(/pixel|/beacon|/tracking).*",
                "resource-type": ["image"],
                "load-type": ["third-party"]
            ],
            "action": ["type": "block"]
        ]
    ]
    
    private var compiledRuleList: WKContentRuleList?
    
    /// Compiles and caches the rule list, then installs it into the given configuration.
    public func install(into configuration: WKWebViewConfiguration,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        if let cached = compiledRuleList {
            configuration.userContentController.add(cached)
            completion(.success(()))
            return
        }
        
        guard let json = try? JSONSerialization.data(withJSONObject: blockingRules),
              let jsonString = String(data: json, encoding: .utf8) else {
            completion(.failure(ContentBlockingError.invalidRules))
            return
        }
        
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "WebKitDemoBlockingRules",
            encodedContentRuleList: jsonString
        ) { [weak self] ruleList, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let ruleList = ruleList else {
                    completion(.failure(ContentBlockingError.compilationFailed))
                    return
                }
                self?.compiledRuleList = ruleList
                configuration.userContentController.add(ruleList)
                completion(.success(()))
            }
        }
    }
    
    /// Removes all content rule lists from the given controller.
    public func uninstall(from controller: WKUserContentController) {
        controller.removeAllContentRuleLists()
    }
    
    enum ContentBlockingError: LocalizedError {
        case invalidRules
        case compilationFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidRules: return "Content blocking rules JSON is invalid."
            case .compilationFailed: return "WKContentRuleList compilation failed."
            }
        }
    }
}
