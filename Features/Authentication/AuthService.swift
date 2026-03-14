import Foundation

public class AuthService: TokenManager, AuthServiceProtocol {
    public static let shared = AuthService()
    
    private let tokenKey = "app_auth_token"
    
    private init() {}
    
    public func getValidToken() -> String? {
        // Simulate reading token from a secure keychain layer
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    public func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    public func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    public func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Simulate network delay to make UI feel realistic
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            if username.lowercased() == "admin" && password == "password" {
                // Mock JWT token base
                let mockToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9." + UUID().uuidString
                self.saveToken(mockToken)
                DispatchQueue.main.async {
                    completion(.success(mockToken))
                }
            } else {
                let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Use admin/password."])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func logout(completion: @escaping () -> Void) {
        clearToken()
        DispatchQueue.main.async {
            completion()
        }
    }
}
