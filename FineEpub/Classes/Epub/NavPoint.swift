//
//  NavPoint.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class NavPoint: NSObject {
    public var playOrder: Int
    public var navLabel: String
    public var content:String
    
    public init(WithPlayOrder playOrder: String?, navLabel: String, content:String) {
        self.navLabel = navLabel
        self.content = content
        
        if playOrder != nil {
            self.playOrder = 2000
        } else {
            self.playOrder = Int(playOrder!)!
        }
    }
    
    public func getContentWithoutTag() -> Uri {
        // TODO check integrity
        guard let indexOf = content.range(of: "#"), indexOf.lowerBound.encodedOffset > 0 else {
            return NavPoint.resourceName2Url(content)
        }
        
        let tempContent = String(content[..<indexOf.lowerBound])
        return NavPoint.resourceName2Url(tempContent)
    }
    
    public static func resourceName2Url(_ resourceName: String) -> Uri {
        let encodedResourceName = resourceName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        return Uri(withHost: "localhost", scheme: "http", port: 1049, path: encodedResourceName!)
    }
    
    public func toString() -> String {
        return "playOrder: \(playOrder), navLabel: \(navLabel), content: \(content)"
    }
}

