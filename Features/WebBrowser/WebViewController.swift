import UIKit
import WebKit

public class WebViewController: UIViewController, JSBridgeDelegate, WebNavigationObserver, WebViewModelDelegate {
    
    private let viewModel: WebViewModel
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var bridgeManager: JSBridgeManager!
    private var navigationDelegate: WebNavigationDelegate!
    
    private var progressObserver: NSKeyValueObservation?
    
    public init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        viewModel.start()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Legacy", style: .plain, target: self, action: #selector(showLegacyWebView))
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadPage))
        navigationItem.leftBarButtonItem = refreshItem
    }
    
    private func setupWebView() {
        bridgeManager = JSBridgeManager()
        bridgeManager.delegate = self
        
        webView = WebViewFactory.createWebView(scriptMessageHandler: bridgeManager)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let securityValidator = SecurityValidator(allowedDomains: AppConfiguration.shared.secureHostWhitelist)
        navigationDelegate = WebNavigationDelegate(securityValidator: securityValidator)
        navigationDelegate.observer = self
        webView.navigationDelegate = navigationDelegate
        
        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            self.didUpdateProgress(Float(progress))
        }
    }
    
    @objc private func reloadPage() {
        webView.reload()
    }
    
    @objc private func showLegacyWebView() {
        navigationController?.pushViewController(LegacyWebViewController(), animated: true)
    }
    
    deinit {
        progressObserver?.invalidate()
    }
    
    // MARK: - WebViewModelDelegate
    
    public func loadURL(_ url: URL) {
        // Evaluate token
        if let token = AuthService.shared.getValidToken() {
            // Inject cookie prior to load
            CookieConfigurator.shared.injectAuthCookie(token: token, domain: url.host ?? AppConfiguration.shared.baseAppHost, dataStore: webView.configuration.websiteDataStore) { [weak self] in
                DispatchQueue.main.async {
                    self?.webView.load(URLRequest(url: url))
                }
            }
        } else {
            webView.load(URLRequest(url: url))
        }
    }
    
    public func didUpdateProgress(_ progress: Float) {
        progressView.progress = progress
        progressView.isHidden = progress >= 1.0
    }
    
    public func performLogout() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    public func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    public func showToast(_ message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: - JSBridgeDelegate
    
    public func handleOpenNativeScreen(screenName: String, params: [String : Any]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Navigating to", message: screenName, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    public func handleShowToast(message: String) {
        DispatchQueue.main.async {
            self.showToast(message)
        }
    }
    
    public func handleRequestNativeData(callbackId: String) {
        let deviceModel = UIDevice.current.model
        let version = UIDevice.current.systemVersion
        // Use evaluateJavaScript to send data back
        
        let safeModel = ScriptSanitizer.sanitizeForJSString(deviceModel)
        let safeVersion = ScriptSanitizer.sanitizeForJSString(version)
        
        let jsCall = "window.receiveNativeData('\(callbackId)', { 'model': '\(safeModel)', 'os': '\(safeVersion)' });"
        
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(jsCall) { result, error in
                if let error = error {
                    print("Error calling back JS: \(error)")
                }
            }
        }
    }
    
    public func handleLogout() {
        viewModel.requestLogout()
    }
    
    // MARK: - WebNavigationObserver
    
    public func didStartLoading() {
        progressView.isHidden = false
        progressView.progress = 0.1
    }
    
    public func didFinishLoading() {
        progressView.isHidden = true
        progressView.progress = 1.0
    }
    
    public func didFailLoading(error: Error) {
        showError(error.localizedDescription)
    }
    
    public func openExternalLink(url: URL) {
        UIApplication.shared.open(url)
    }
}
