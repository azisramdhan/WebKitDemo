# WebKitDemo

An iOS demo application showcasing a **production-ready WebKit integration** built with Clean Architecture principles. It covers the full breadth of the `WKWebView` API — from the JS bridge and cookie auth to content blocking, file downloads, async scripting, and more.

---

## Features

### Core
- **`WKWebView` integration** with progress tracking and navigation controls
- **`WKUIDelegate`** — native alert/confirm/prompt dialogs and `target=_blank` handling
- **Custom User Agent** — append to system UA or replace entirely
- **Back-Forward List** — programmatic navigation via `WKBackForwardList`
- **`WKProcessPool`** — shared session/cookie state across multiple web views

### JavaScript Bridge
- **`WKScriptMessageHandler`** — one-way JS → Native bridge (actions: `openNativeScreen`, `showToast`, `requestNativeData`, `logoutUser`)
- **`WKScriptMessageHandlerWithReply`** — two-way async bridge; JS can `await` a native response (iOS 14+)
- **`callAsyncJavaScript`** — cleaner async JS evaluation with structured arguments (iOS 14+)

### Security & Privacy
- **`SecurityValidator`** — domain whitelist and scheme validation
- **`ScriptSanitizer`** — payload sanitization before JS eval
- **`WKContentRuleList`** — compile-time content blocking (ads, trackers)
- **App-Bound Domains** — engine-level domain restriction for privacy (iOS 14+)

### Networking & Data
- **Cookie Authentication** — inject HTTP auth tokens into `WKHTTPCookieStore`
- **`WKURLSchemeHandler`** — intercept and serve custom `wkdemo://` scheme requests
- **`WKDownloadDelegate`** — file download handling with progress (iOS 15+)

### Media & UX
- **Media Playback Config** — inline playback, autoplay, AirPlay
- **Find-in-Page** — `WKFindInteraction` search bar integration (iOS 16+)
- **`WKWebpagePreferences`** — per-navigation JS toggle and content mode (mobile/desktop)
- **Screenshot & PDF** — `takeSnapshot` and `createPDF` (iOS 14+)

### Login & Navigation
- **Login Flow** — native username/password screen with `AuthService`
- **Local HTML Demo** — bundled `index.html` for offline bridge testing
- **Legacy Reference** — `LegacyWebViewController` for `UIWebView` migration context

---

## Architecture

```
WebKitDemo/
├── App/                          # AppDelegate, SceneDelegate
├── Configuration/                # AppConfiguration (base URL, whitelist)
├── Domain/
│   ├── Models/                   # JSMessage DTO
│   └── Auth/                     # TokenManager protocol
├── Security/
│   ├── SecurityValidator.swift   # URL and scheme whitelist checking
│   └── ScriptSanitizer.swift     # Payload sanitization before JS eval
├── Networking/
│   └── CookieConfigurator.swift  # Injects auth tokens into WKHTTPCookieStore
├── Bridge/
│   ├── JSBridgeManager.swift     # WKScriptMessageHandler + action routing
│   └── AsyncJSBridgeManager.swift# WKScriptMessageHandlerWithReply (iOS 14+)
├── WebViewContainer/
│   ├── WebViewFactory.swift      # WKWebView factory (pool, UA, media config)
│   ├── WebNavigationDelegate.swift # Navigation policy + WKWebpagePreferences
│   ├── WebUIDelegate.swift       # Dialogs, new window (WKUIDelegate)
│   ├── CustomSchemeHandler.swift # WKURLSchemeHandler for wkdemo://
│   ├── ContentBlockingManager.swift # WKContentRuleList
│   ├── DownloadManager.swift     # WKDownloadDelegate (iOS 15+)
│   └── BackForwardNavigator.swift# WKBackForwardList wrapper
├── Features/
│   ├── Login/                    # LoginViewController + AuthService
│   ├── WebBrowser/               # WebViewController, WebViewModel
│   │   ├── WebSnapshotManager.swift # takeSnapshot + createPDF
│   │   └── FindInPageManager.swift  # WKFindInteraction (iOS 16+)
│   └── UIWebViewMigration/       # LegacyWebViewController (migration ref)
├── Resources/
│   └── HTMLSamples/              # index.html + bridge.js demo page
├── Tests/                        # XCTest unit tests (≥91% coverage)
└── UITests/                      # XCTest UI tests
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

## Contributing

Commit messages follow the **[Conventional Commits](https://www.conventionalcommits.org)** specification:

```
<type>(<scope>): <summary>
```

Common types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.

---

## License

This project is for demonstration purposes.


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
