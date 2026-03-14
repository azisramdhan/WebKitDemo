import Foundation

public struct JSMessage {
    public let action: String
    public let data: [String: Any]
    
    public init?(from dictionary: [String: Any]) {
        guard let action = dictionary["action"] as? String else {
            return nil
        }
        self.action = action
        self.data = dictionary["data"] as? [String: Any] ?? [:]
    }
}
