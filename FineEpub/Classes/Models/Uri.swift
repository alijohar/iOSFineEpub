//
//  Uri.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class Uri: NSObject {
    var uri: String
    var host: String
    var scheme: String
    var port: Int
    var path: String
    
    public init(withHost host: String, scheme: String, port: Int, path: String) {
        self.host = host
        self.scheme = scheme
        
        // the removingPercentEncoding wont remove space sign so i have to remove it manually
        self.path = path.removingPercentEncoding!.replacingOccurrences(of: "%20", with: " ")
        self.port = port
        
        self.uri = String(format: "%@://%@:%d/%@", self.scheme, self.host, self.port, self.path)
    }
    
    public init(withUri uri: String) {
        self.host = "localhost"
        self.scheme = "http"
        self.port = 1049
        self.path = ""
        
        // the removingPercentEncoding wont remove space sign so i have to remove it manually
        self.uri = uri.removingPercentEncoding!.replacingOccurrences(of: "%20", with: " ")
    }
    
    public func getPath() -> String? {
        let removeStr = String(format: "%@://%@:%d/", self.scheme, self.host, self.port)
        guard let replaceRange = uri.range(of: removeStr) else {
            return nil
        }
        
        return uri.replacingCharacters(in: replaceRange, with: "")
    }
    
    public func getString() -> String {
        return uri
    }
}
