# WebKitDemo

An iOS demo application showcasing a **production-ready WebKit integration** built with Clean Architecture principles. It demonstrates how to embed `WKWebView` in a real-world app with a native–JavaScript bridge, security validation, cookie authentication, and full unit + UI test coverage.

---

## Features

- **`WKWebView` integration** with progress tracking and navigation controls
- **JavaScript ↔ Native Bridge** via `WKScriptMessageHandler` supporting actions:
  - `openNativeScreen` — push native screens from JS
  - `showToast` — display native toasts
  - `requestNativeData` — send data from native to JS
  - `logoutUser` — trigger native logout flow
- **Security Layer** — domain whitelist validation and script sanitization
- **Cookie Authentication** — inject HTTP auth tokens into `WKHTTPCookieStore`
- **Login Flow** — native username/password screen with `AuthService`
- **Local HTML Demo** — bundled `index.html` for offline bridge testing
- **Legacy Reference** — `LegacyWebViewController` showing deprecated `UIWebView` migration context

---

## Architecture

```
WebKitDemo/
├── App/                        # AppDelegate, SceneDelegate
├── Configuration/              # AppConfiguration (base URL, whitelist)
├── Domain/
│   ├── Models/                 # JSMessage DTO
│   └── Auth/                   # TokenManager protocol
├── Security/
│   ├── SecurityValidator.swift # URL and scheme whitelist checking
│   └── ScriptSanitizer.swift   # Payload sanitization before JS eval
├── Networking/
│   └── CookieConfigurator.swift# Injects auth tokens into WKHTTPCookieStore
├── Bridge/
│   └── JSBridgeManager.swift   # WKScriptMessageHandler + action routing
├── WebViewContainer/
│   ├── WebViewFactory.swift    # WKWebView factory with process pool setup
│   └── WebNavigationDelegate.swift # Navigation policy + loading events
├── Features/
│   ├── Login/                  # LoginViewController + AuthService
│   ├── WebBrowser/             # WebViewController + WebViewModel
│   └── UIWebViewMigration/     # LegacyWebViewController (migration ref)
├── Resources/
│   └── HTMLSamples/            # index.html + bridge.js demo page
├── Tests/                      # XCTest unit tests (≥91% coverage)
└── UITests/                    # XCTest UI tests
```

---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 16+ |
| iOS Deployment Target | 16.0+ |
| XcodeGen | 2.x |

---

## Getting Started

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd WebKitDemo
xcodegen generate
```

### 3. Open in Xcode

```bash
open WebKitDemo.xcodeproj
```

### 4. Run the app

Select the `WebKitDemo` scheme and any iOS 16+ simulator, then press **⌘R**.

---

## Running Tests

```bash
xcodebuild test \
  -project WebKitDemo.xcodeproj \
  -scheme WebKitDemo \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -enableCodeCoverage YES
```

---

## Test Coverage

| Component | Coverage |
|-----------|----------|
| `AppDelegate` | 100% |
| `SceneDelegate` | 100% |
| `SecurityValidator` | 100% |
| `WebViewFactory` | 100% |
| `WebNavigationDelegate` | 96% |
| `JSBridgeManager` | 91% |
| `CookieConfigurator` | ~100% |
| **Overall** | **~92%** |

---

## Demo Login

Use the bundled credentials on the login screen:

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `password` |

Or tap **"Skip to Local HTML Demo"** to load the bundled bridge test page directly.

---

## Project Configuration

The project is managed via **XcodeGen** (`project.yml`).  
Bundle ID prefix: `com.azisramdhan`

| Target | Bundle ID |
|--------|-----------|
| App | `com.azisramdhan.WebKitDemo` |
| Unit Tests | `com.azisramdhan.WebKitDemoTests` |
| UI Tests | `com.azisramdhan.WebKitDemoUITests` |

---

## License

This project is for demonstration purposes.
