import Foundation

public protocol TokenManager {
    func getValidToken() -> String?
    func saveToken(_ token: String)
    func clearToken()
}

public protocol AuthServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func logout(completion: @escaping () -> Void)
}
