import Foundation

public protocol WebViewModelDelegate: AnyObject {
    func didUpdateProgress(_ progress: Float)
    func loadURL(_ url: URL)
    func performLogout()
    func showError(_ message: String)
    func showToast(_ message: String)
}

public class WebViewModel {
    
    public weak var delegate: WebViewModelDelegate?
    private let authService: AuthServiceProtocol
    public let startURL: URL
    
    public init(startURL: URL, authService: AuthServiceProtocol = AuthService.shared) {
        self.startURL = startURL
        self.authService = authService
    }
    
    public func start() {
        delegate?.loadURL(startURL)
    }
    
    public func requestLogout() {
        authService.logout { [weak self] in
            self?.delegate?.performLogout()
        }
    }
}
