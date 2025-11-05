import Foundation
import WatchConnectivity

protocol WatchConnectivityDelegate: AnyObject {
    func didReceiveData(_ data: [String: Any])
}

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    static let shared = WatchConnectivityManager()
    weak var delegate: WatchConnectivityDelegate?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendMessage(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        delegate?.didReceiveData(message)
    }
}
