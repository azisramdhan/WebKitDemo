const Bridge = {
    _callbacks: {},
    
    postMessage: function(action, data = {}) {
        const message = {
            action: action,
            data: data
        };
        
        // Ensure webkit handler is available (WKUserContentController injection)
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeBridge) {
            window.webkit.messageHandlers.nativeBridge.postMessage(message);
        } else {
            console.warn("Native bridge not found. Fallback offline mode.");
        }
    },
    
    openNativeScreen: function(screenName) {
        this.postMessage("openNativeScreen", { screenName: screenName });
    },
    
    showToast: function(message) {
        this.postMessage("showToast", { message: message });
    },
    
    logout: function() {
        this.postMessage("logoutUser");
    },
    
    requestNativeData: function() {
        return new Promise((resolve, reject) => {
            const callbackId = "cb_" + Math.random().toString(36).substr(2, 9);
            
            // Register promise callbacks internally
            this._callbacks[callbackId] = { resolve, reject };
            
            this.postMessage("requestNativeData", { callbackId: callbackId });
            
            // Timeout out after 5 seconds to prevent memory leaks if native fails to respond
            setTimeout(() => {
                if (this._callbacks[callbackId]) {
                    this._callbacks[callbackId].reject("Timeout waiting for native response.");
                    delete this._callbacks[callbackId];
                }
            }, 5000);
        });
    }
};

// Global function exposed for native execution via evaluateJavaScript
window.receiveNativeData = function(callbackId, data) {
    if (Bridge._callbacks[callbackId]) {
        Bridge._callbacks[callbackId].resolve(data);
        delete Bridge._callbacks[callbackId];
    }
};
