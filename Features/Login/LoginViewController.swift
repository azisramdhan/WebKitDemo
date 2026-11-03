import UIKit

public class LoginViewController: UIViewController {
    
    private let authService = AuthService.shared
    private let bundle: Bundle
    
    public init(bundle: Bundle = .main) {
        self.bundle = bundle
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Login"
        
        let titleLabel = UILabel()
        titleLabel.text = "WebKit Demo App"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "admin / password  ·  PR #1"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        let usernameField = UITextField()
        usernameField.placeholder = "Username"
        usernameField.accessibilityIdentifier = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        
        let passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.accessibilityIdentifier = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.accessibilityIdentifier = "Log In"
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        
        let localDemoButton = UIButton(type: .system)
        localDemoButton.setTitle("Skip to Local HTML Demo", for: .normal)
        localDemoButton.accessibilityIdentifier = "Skip to Local HTML Demo"
        localDemoButton.addTarget(self, action: #selector(localDemoTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, usernameField, passwordField, loginButton, localDemoButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(40, after: subtitleLabel)
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.usernameField = usernameField
        self.passwordField = passwordField
        self.loginButton = loginButton
    }
    
    private var usernameField: UITextField!
    private var passwordField: UITextField!
    private var loginButton: UIButton!
    
    @objc func loginTapped() {
        guard let user = usernameField.text, !user.isEmpty,
              let pass = passwordField.text, !pass.isEmpty else { return }
        
        loginButton.setTitle("Loading...", for: .normal)
        loginButton.isEnabled = false
        
        authService.login(username: user, password: pass) { [weak self] result in
            guard let self = self else { return }
            self.loginButton.setTitle("Log In", for: .normal)
            self.loginButton.isEnabled = true
            
            switch result {
            case .success(_):
                self.navigateToWeb(url: URL(string: "https://example.com")!)
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func localDemoTapped() {
        guard let path = bundle.path(forResource: "index", ofType: "html"),
              let url = URL(string: "file://\(path)") else {
            let alert = UIAlertController(title: "Error", message: "Local HTML file missing in bundle", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        navigateToWeb(url: url)
    }
    
    func navigateToWeb(url: URL) {
        let viewModel = WebViewModel(startURL: url)
        let webVC = WebViewController(viewModel: viewModel)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

