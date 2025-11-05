import Foundation
import WatchConnectivity

protocol IOSConnectivityDelegate: AnyObject {
    func didReceiveData(_ data: [String: Any])
}

class IOSConnectivity: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print(error?.localizedDescription)
      
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    static let shared = IOSConnectivity()
    weak var delegate: IOSConnectivityDelegate?

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
