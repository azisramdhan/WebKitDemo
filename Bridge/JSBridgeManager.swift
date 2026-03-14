import Foundation
import WebKit

public protocol JSBridgeDelegate: AnyObject {
    func handleOpenNativeScreen(screenName: String, params: [String: Any])
    func handleShowToast(message: String)
    func handleRequestNativeData(callbackId: String)
    func handleLogout()
}

public class JSBridgeManager: NSObject, WKScriptMessageHandler {
    
    public weak var delegate: JSBridgeDelegate?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // Ensure the message format strictly matches expected types
        guard message.name == "nativeBridge",
              let bodyDict = message.body as? [String: Any],
              let jsMessage = JSMessage(from: bodyDict) else {
            print("Invalid bridge message format received")
            return
        }
        
        // Route actions back to the logical delegate (e.g., View Controller or ViewModel)
        switch jsMessage.action {
        case "openNativeScreen":
            let screenName = jsMessage.data["screenName"] as? String ?? ""
            delegate?.handleOpenNativeScreen(screenName: screenName, params: jsMessage.data)
            
        case "showToast":
            let msg = jsMessage.data["message"] as? String ?? ""
            delegate?.handleShowToast(message: msg)
            
        case "requestNativeData":
            let callbackId = jsMessage.data["callbackId"] as? String ?? ""
            delegate?.handleRequestNativeData(callbackId: callbackId)
            
        case "logoutUser":
            delegate?.handleLogout()
            
        default:
            print("Unknown bridge action: \(jsMessage.action)")
        }
    }
}
