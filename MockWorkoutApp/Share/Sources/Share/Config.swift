//
//  Config.swift
//  Share
//
//  Created by nanghuy on 12/11/25.
//

import Foundation

public struct Config {
    
    nonisolated(unsafe) public static let shared = Config()
    
    public let baseURL: String
    
    private init() {
        
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [AnyHashable: Any],
              let settings = plist["AppSettings"] as? [AnyHashable: Any] else {
            baseURL = ""
            return
        }
        baseURL = settings["BASE_URL"] as? String ?? ""
    }
}
