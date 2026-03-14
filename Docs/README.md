# WebKit Demo App

A production-ready iOS application focusing squarely on advanced WebKit integration using **Swift** and **WKWebView**. This project demonstrates how to securely bridge web environments and native app modules enforcing Clean Architecture principles.

## 🚀 Features

- **WKWebView Architecture**: Best practices with shared `WKProcessPool`, progress delegation, and memory optimization.
- **Robust JavaScript Bridge**: Typed bridging via `WKScriptMessageHandler` translating JSON intents (`openNativeScreen`, `showToast`) directly into native actions.
- **Authentication Handshake**: Sync native login tokens silently across into WebKit realms using securely scoped `WKHTTPCookieStore`.
- **Security Protections**: Whitelisted domain evaluation logic, URL validation mapping, script sanitizers, and rigorous `WKNavigationDelegate` handlers managing external Safari routing vs internal App routing safely.
- **Legacy Preservation**: Educational migration path analysis translating legacy `UIWebView` flows to modern specs.
- **Testing Capabilities**: Fully equipped with XCTest Suites extending across Unit boundary definitions and visual automated UI regressions.

## 🛠️ Installation & Generating the Xcode Project

This repository utilizes **XcodeGen** to maintain clear version control over the project file setup.

1. Ensure XcodeGen is installed:
   ```bash
   brew install xcodegen
   ```
2. Navigate to the root directory and execute:
   ```bash
   xcodegen generate
   ```
3. Open the newly generated `WebKitDemo.xcodeproj`.

## Structure Highlight

```
├── App                 - Lifecycles (AppDelegate/SceneDelegate/Info)
├── Bridge              - JSMessage models and Native routers
├── Domain              - Shared protocol boundaries (Auth)
├── Features            - Visual Native and Web Controllers
├── Networking          - Cookie persistence bridges
├── Resources           - Contained static HTML samples for offline bridge routing
├── Security            - Trust evaluation logic and Whitelist checkers
├── WebViewContainer    - Reusable Factory and Session configurations
```

## Security Strategy 🔒
This environment strictly restricts dynamic evaluation payloads unless evaluated via the `ScriptSanitizer`. Top-level navigations are parsed at the `decidePolicyFor` level against a `secureHostWhitelist` ensuring outbound or unauthorized transitions are offloaded to standard external Safari frameworks.

## CI/CD Note
Use `.github/workflows/swift.yml` to trigger standard `xcodebuild -workspace WebKitDemo -scheme WebKitDemo test` automation across actions.
